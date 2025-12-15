# Controlador para criação e distribuição de formulários de avaliação.
# Apenas administradores podem acessar.
class FormulariosController < ApplicationController
  before_action :authenticate_admin

  # Lista os formulários existentes.
  #
  # Retorno:
  #   - Renderiza a view :index.
  #
  # Efeitos Colaterais:
  #   - Define @formularios incluindo templates e turmas associadas.
  def index
    @formularios = Formulario.all.includes(:template, :turma)
  end

  # Renderiza formulário para criar novo envio de avaliação.
  #
  # Retorno:
  #   - Renderiza a view :new.
  #
  # Efeitos Colaterais:
  #   - Define @formulario como nova instância.
  #   - Define @templates com todos templates disponíveis.
  #   - Define @turmas com todas turmas disponíveis.
  def new
    @formulario = Formulario.new
    @templates = Template.all
    @turmas = Turma.all
  end

  def show
    @formulario = Formulario.find(params[:id])
  end

  # Processa a criação e distribuição dos formulários para as turmas selecionadas.
  #
  # Argumentos:
  #   - params[:formulario][:template_id] (Integer): ID do template selecionado.
  #   - params[:turma_ids] (Array<Integer>): Lista de IDs das turmas para distribuição.
  #
  # Retorno:
  #   - Redireciona para formularios_path com mensagem de sucesso se a transação ocorrer bem.
  #   - Redireciona para new_formulario_path com alerta se houver erro (exception).
  #
  # Efeitos Colaterais:
  #   - Cria múltiplos registros de Formulario (um por turma).
  #   - Cria registros de Resposta (vazios) para cada aluno.
  #   - Abre transação no banco de dados.
  #   - Define flash[:notice] em sucesso ou flash[:alert] em erro.
  def create
    template = Template.find(formulario_params[:template_id])
    
    ActiveRecord::Base.transaction do
      formulario_params[:turma_ids].each do |turma_id|
        turma = Turma.find(turma_id)
        # O método distribuir_formulario da Turma já cria o Formulario e as Respostas
        turma.distribuir_formulario(template)
      end
    end

    redirect_to formularios_path, notice: success_message
  rescue StandardError => e
    handle_error(e)
  end

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

  def authenticate_admin
    redirect_to root_path, alert: "Acesso restrito." unless current_usuario&.admin?
  end

  # Sanitiza parâmetros do formulário.
  #
  # Retorno:
  #   - (ActionController::Parameters): Hash contendo :template_id, :titulo_envio, :data_encerramento e :turma_ids.
  def formulario_params
    params.require(:formulario).permit(
      :template_id, 
      :titulo_envio, 
      :data_encerramento,
      turma_ids: []
    )
  end

  # Gera respostas vazias para todos os alunos da turma.
  #
  # Argumentos:
  #   - form (Formulario): O formulário criado.
  #   - turma (Turma): A turma alvo.
  #
  # Efeitos Colaterais:
  #   - Cria registros Resposta.
  def generate_empty_responses!(form, turma)
    turma.matriculas.each do |matricula|
      Resposta.create!(
        formulario: form,
        participante: matricula.usuario,
        data_submissao: nil
      )
    end
  end

  # Gera mensagem de sucesso baseada no número de turmas.
  #
  # Retorno:
  #   - (String): Mensagem formatada.
  def success_message
    count = params[:turma_ids]&.count || 0
    "Formulário distribuído com sucesso para #{count} turmas"
  end

  # Lida com erros na criação.
  #
  # Argumentos:
  #   - exception (StandardError): O erro capturado.
  #
  # Efeitos Colaterais:
  #   - Redireciona com alerta.
  def handle_error(exception)
    flash[:alert] = "Erro ao distribuir: #{exception.message}"
    redirect_to new_formulario_path
  end
end