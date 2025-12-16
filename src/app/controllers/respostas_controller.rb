# Controlador para preenchimento e submissão de avaliações pelos alunos.
class RespostasController < ApplicationController
  before_action :require_login
  before_action :set_formulario
  before_action :verifica_participacao

  # Renderiza o formulário de resposta para uma avaliação específica.
  #
  # Retorno:
  #   - Renderiza a view :new.
  #
  # Efeitos Colaterais:
  #   - Define @questions com as questões do formulário ordendas.
  #   - Define @resposta como uma nova instância (ou existente não submetida).
  def new
    load_questions
    @resposta = Resposta.new
  end

  # Processa o envio da resposta com transação para garantir atomicidade.
  #
  # Argumentos:
  #   - params[:respostas] (Hash): Mapa de 'id_questao' => 'resposta_valor'.
  #
  # Retorno:
  #   - Redireciona para root_path com mensagem de sucesso se tudo for salvo.
  #   - Renderiza a view :new com status :unprocessable_content se houver erro (transação falhar).
  #
  # Efeitos Colaterais:
  #   - Cria/Atualiza registros de Resposta e RespostaItem.
  #   - Define flash[:notice] em sucesso ou flash[:alert] em erro.
  #   - Recarrega @questions em caso de erro para re-renderizar o form.
  def create
    @resposta = find_or_init_resposta
    
    if submit_response_transaction
      redirect_to root_path, notice: "Avaliação enviada com sucesso. Obrigado!"
    else
      load_questions
      flash.now[:alert] = "Houve um erro ao enviar suas respostas. Verifique os campos abaixo."
      render :new, status: :unprocessable_content
    end
  end

  private

  # Define o formulário com base no ID da URL.
  #
  # Efeitos Colaterais:
  #   - Define @formulario.
  def set_formulario
    @formulario = Formulario.find(params[:formulario_id])
  end

  # Carrega as questões do formulário.
  #
  # Efeitos Colaterais:
  #   - Define @questions.
  def load_questions
    @questions = @formulario.template.questoes.includes(:opcoes).order(:id)
  end

  # Encontra ou inicializa a resposta do usuário.
  #
  # Retorno:
  #   - (Resposta): A resposta do usuário.
  def find_or_init_resposta
    Resposta.find_or_initialize_by(
      formulario: @formulario,
      participante: current_usuario
    )
  end

  # Wrapper transacional para submissão.
  #
  # Retorno:
  #   - (Boolean): Sucesso ou falha.
  #
  # Efeitos Colaterais:
  #   - Chama métodos de persistência.
  def submit_response_transaction
    ActiveRecord::Base.transaction do
      save_resposta_header!
      process_all_items!
      finalize_submission!
      true
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::Rollback
    false
  end

  # Salva o cabeçalho da resposta.
  #
  # Efeitos Colaterais:
  #   - Salva @resposta.
  def save_resposta_header!
    raise ActiveRecord::Rollback unless @resposta.save
  end

  # Processa todos os itens de resposta submetidos.
  #
  # Argumentos:
  #   - params[:respostas]
  #
  # Efeitos Colaterais:
  #   - Chama save_single_item! para cada item.
  def process_all_items!
    return unless params[:respostas].present?

    params[:respostas].each do |questao_id, valor|
      save_single_item!(questao_id, valor)
    end
  end

  # Salva um item individual de resposta.
  #
  # Argumentos:
  #   - questao_id (Integer): ID da questão.
  #   - valor (String): Valor da resposta.
  #
  # Efeitos Colaterais:
  #   - Cria/Atualiza RespostaItem.
  def save_single_item!(questao_id, valor)
    questao = Questao.find(questao_id)
    item = RespostaItem.find_or_initialize_by(resposta: @resposta, questao: questao)

    apply_value_to_item(item, questao, valor)

    unless item.save
      @resposta.errors.add(:base, "Questão '#{questao.enunciado}': #{item.errors.full_messages.join(', ')}")
      raise ActiveRecord::Rollback
    end
  end

  # Aplica o valor ao item de resposta dependendo do tipo.
  #
  # Argumentos:
  #   - item (RespostaItem): Item a ser preenchido.
  #   - questao (Questao): A questão.
  #   - valor (String): A resposta bruta.
  def apply_value_to_item(item, questao, valor)
    if questao.multipla_escolha?
      handle_multiple_choice(item, questao, valor)
    else
      item.texto_resposta = valor
      item.opcao_escolhida = nil
    end
  end

  # Processa respostas de múltipla escolha.
  #
  # Argumentos:
  #   - item, questao, valor
  #
  # Efeitos Colaterais:
  #   - Busca opção correspondente.
  def handle_multiple_choice(item, questao, valor)
    opcao = questao.opcoes.find_by(texto_opcao: valor)
    if opcao
      item.opcao_escolhida = opcao
    else
      item.errors.add(:base, "Opção inválida selecionada.")
    end
  end

  # Finaliza a submissão marcando o timestamp.
  #
  # Efeitos Colaterais:
  #   - Atualiza data_submissao.
  def finalize_submission!
    @resposta.update!(data_submissao: Time.current)
  end

  # Verifica permissões e condições para responder.
  #
  # Efeitos Colaterais:
  #   - Redireciona se inválido.
  def verifica_participacao
    return deny_access unless valid_participant?
    return form_closed if form_expired?
    return already_answered if user_already_responded?
  end

  # Verifica se o usuário pode participar.
  #
  # Retorno:
  #   - (Boolean): True se discente.
  def valid_participant?
    current_usuario&.discente?
  end

  # Verifica se o formulário expirou.
  #
  # Retorno:
  #   - (Boolean): True se data_encerramento passou.
  def form_expired?
    @formulario.data_encerramento.present? && @formulario.data_encerramento < Time.current
  end

  # Verifica se o usuário já respondeu.
  #
  # Retorno:
  #   - (Boolean): True se já existe resposta submetida.
  def user_already_responded?
    Resposta.where(formulario: @formulario, participante: current_usuario)
            .where.not(data_submissao: nil)
            .exists?
  end

  # Redireciona acesso negado.
  def deny_access
    redirect_to root_path, alert: "Acesso negado."
  end

  # Redireciona formulário fechado.
  def form_closed
    redirect_to root_path, alert: "Este formulário não está mais aceitando respostas."
  end

  # Redireciona já respondido.
  def already_answered
    redirect_to root_path, alert: "Você já respondeu este formulário."
  end
end