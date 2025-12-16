# Controlador para criação e distribuição de formulários de avaliação.
class FormulariosController < ApplicationController
  before_action :require_login
  before_action :authorize_admin, only: %i[new create index]

  # Lista os formulários existentes.
  #
  # Retorno:
  #   - Renderiza a view :index.
  def index
    @templates = Template.all
    @turmas = Turma.includes(:materia).all
    @formularios = Formulario.all.includes(:template, :turma)
  end

  # Renderiza formulário para criar novo envio de avaliação.
  #
  # Retorno:
  #   - Renderiza a view :new.
  def new
    @templates = Template.all
    @turmas = Turma.includes(:materia).all
  end

  # Exibe os detalhes de um formulário enviado.
  #
  # Argumentos:
  #   - params[:id] (Integer): ID do formulário.
  #
  # Retorno:
  #   - Renderiza a view :show.
  def show
    @formulario = Formulario.find(params[:id])
  end

  # Processa a criação e distribuição dos formulários.
  #
  # Retorno:
  #   - Redireciona para formularios_path se sucesso.
  #   - Renderiza novamente em falha.
  #
  # Efeitos Colaterais:
  #   - Cria Formularios e Respostas.
  def create
    return unless valid_params?

    distribute_forms_transaction

    redirect_to formularios_path, notice: success_message
  rescue ActiveRecord::RecordInvalid => e
    handle_error(e)
  end

  # Lista avaliações pendentes para o usuário atual (Discente).
  #
  # Retorno:
  #   - Renderiza a view :pendentes.
  #
  # Efeitos Colaterais:
  #   - Define @respostas_pendentes.
  def pendentes
    if current_usuario.matriculas.empty?
      flash.now[:alert] = "Você não possui turmas cadastradas"
      @respostas_pendentes = []
    else
      @respostas_pendentes = Resposta.where(participante: current_usuario, data_submissao: nil)
                                     .includes(formulario: [:template, { turma: :materia }])
    end
  end

  private

  # Garante acesso apenas a administradores.
  def authorize_admin
    redirect_to root_path, alert: "Acesso restrito." unless current_usuario&.admin?
  end

  # Valida os parâmetros de criação.
  #
  # Retorno:
  #   - (Boolean): true se válido, false caso contrário.
  def valid_params?
    if params[:template_id].blank?
      redirect_with_alert("Selecione um template")
      return false
    end

    if (params[:turma_ids] || []).empty?
      redirect_with_alert("Selecione pelo menos uma turma")
      return false
    end

    true
  end

  # Auxiliar para redirecionamento com alerta.
  def redirect_with_alert(msg)
    flash[:alert] = msg
    redirect_to new_formulario_path
  end

  # Executa a distribuição de formulários em transação.
  def distribute_forms_transaction
    template = Template.find(params[:template_id])
    
    ActiveRecord::Base.transaction do
      params[:turma_ids].each do |turma_id|
        process_single_distribution(turma_id, template)
      end
    end
  end

  # Distribui formulário para uma única turma.
  def process_single_distribution(turma_id, template)
    turma = Turma.find(turma_id)
    
    form = create_formulario!(turma, template)
    generate_empty_responses!(form, turma)
  end

  # Cria o registro Formulario.
  def create_formulario!(turma, template)
    Formulario.create!(
      template_id: template.id,
      turma_id: turma.id,
      titulo_envio: template.titulo,
      data_criacao: Time.current,
      data_encerramento: params[:data_encerramento]
    )
  end

  # Gera respostas vazias para os alunos.
  def generate_empty_responses!(form, turma)
    turma.matriculas.each do |matricula|
      Resposta.create!(
        formulario: form,
        participante: matricula.usuario,
        data_submissao: nil
      )
    end
  end

  # Gera mensagem de sucesso.
  def success_message
    count = params[:turma_ids]&.count || 0
    "Formulário distribuído com sucesso para #{count} turmas"
  end

  # Trata erros de criação.
  def handle_error(exception)
    flash[:alert] = "Erro ao distribuir: #{exception.message}"
    redirect_to new_formulario_path
  end
end