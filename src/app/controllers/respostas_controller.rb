class RespostasController < ApplicationController
  before_action :require_login
  before_action :set_formulario
  before_action :verifica_participacao

  def new
    load_questions
    @resposta = Resposta.new
  end

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

  def set_formulario
    @formulario = Formulario.find(params[:formulario_id])
  end

  def load_questions
    @questions = @formulario.template.questoes.includes(:opcoes).order(:id)
  end

  def find_or_init_resposta
    Resposta.find_or_initialize_by(
      formulario: @formulario,
      participante: current_usuario
    )
  end

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

  def save_resposta_header!
    raise ActiveRecord::Rollback unless @resposta.save
  end

  def process_all_items!
    return unless params[:respostas].present?

    params[:respostas].each do |questao_id, valor|
      save_single_item!(questao_id, valor)
    end
  end

  def save_single_item!(questao_id, valor)
    questao = Questao.find(questao_id)
    item = RespostaItem.find_or_initialize_by(resposta: @resposta, questao: questao)

    apply_value_to_item(item, questao, valor)

    unless item.save
      @resposta.errors.add(:base, "Questão '#{questao.enunciado}': #{item.errors.full_messages.join(', ')}")
      raise ActiveRecord::Rollback
    end
  end

  def apply_value_to_item(item, questao, valor)
    if questao.multipla_escolha?
      handle_multiple_choice(item, questao, valor)
    else
      item.texto_resposta = valor
      item.opcao_escolhida = nil
    end
  end

  def handle_multiple_choice(item, questao, valor)
    opcao = questao.opcoes.find_by(texto_opcao: valor)
    if opcao
      item.opcao_escolhida = opcao
    else
      item.errors.add(:base, "Opção inválida selecionada.")
    end
  end

  def finalize_submission!
    @resposta.update!(data_submissao: Time.current)
  end

  def verifica_participacao
    return deny_access unless valid_participant?
    return form_closed if form_expired?
    return already_answered if user_already_responded?
  end

  def valid_participant?
    current_usuario&.discente?
  end

  def form_expired?
    @formulario.data_encerramento.present? && @formulario.data_encerramento < Time.current
  end

  def user_already_responded?
    Resposta.where(formulario: @formulario, participante: current_usuario)
            .where.not(data_submissao: nil)
            .exists?
  end

  def deny_access
    redirect_to root_path, alert: "Acesso negado."
  end

  def form_closed
    redirect_to root_path, alert: "Este formulário não está mais aceitando respostas."
  end

  def already_answered
    redirect_to root_path, alert: "Você já respondeu este formulário."
  end
end