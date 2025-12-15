# Controlador para gerenciamento das questões dentro de um template.
# Permite adicionar, remover e atualizar questões dinamicamente.
class TemplateQuestionsController < ApplicationController
  before_action :set_template
  before_action :set_question, only: %i[update destroy add_alternative]

  CHOICE_TYPES = %w[radio checkbox].freeze

  # Adiciona uma nova questão ao template.
  #
  # Retorno:
  #   - (NilClass): Redireciona para visualização do template.
  #
  # Efeitos Colaterais:
  #   - Cria nova TemplateQuestion.
  def create
    @template.template_questions.create(
      title: "Nova Questão",
      question_type: "text",
      content: []
    )
    redirect_to edit_template_path(@template), notice: 'Questão adicionada.'
  end

  # Atualiza uma questão existente.
  #
  # Argumentos:
  #   - params[:template_question]: Atributos da questão.
  #   - params[:alternatives]: Alternativas para questões de escolha.
  #
  # Retorno:
  #   - (NilClass): Redireciona em sucesso.
  #
  # Efeitos Colaterais:
  #   - Atualiza atributos.
  #   - Adiciona alternativa se solicitado.
  def update
    prepare_attributes

    return handle_add_alternative_action if adding_alternative_button?

    if type_changed_or_autosave?
      return handle_type_change
    end

    perform_standard_save
  end

  # Remove uma questão do template.
  #
  # Efeitos Colaterais:
  #   - Deleta o registro se houver mais de uma questão.
  def destroy
    if @template.template_questions.count <= 1
      redirect_to edit_template_path(@template), alert: 'não é possível salvar template sem questões'
    else
      @question.destroy
      redirect_to edit_template_path(@template), notice: 'template alterado com sucesso'
    end
  end

  # Adiciona uma alternativa vazia a uma questão de escolha.
  #
  # Efeitos Colaterais:
  #   - Modifica o array de conteúdo da questão.
  def add_alternative
    append_empty_option
    save_without_validation_and_redirect
  end

  private

  # Setta o template pai.
  def set_template
    @template = Template.find(params[:template_id])
  end

  # Setta a questão alvo.
  def set_question
    @question = @template.template_questions.find(params[:id])
  end

  # Sanitiza parâmetros da questão.
  def question_params
    params.require(:template_question).permit(:title, :question_type)
  end

  # Prepara atributos para atualização.
  def prepare_attributes
    @question.content = params[:alternatives] if params[:alternatives]
    @question.assign_attributes(question_params)
  end

  # Verifica se a ação é adicionar alternativa.
  def adding_alternative_button?
    params[:commit] == "Adicionar Alternativa"
  end

  # Verifica se o tipo mudou ou é um save automático.
  def type_changed_or_autosave?
    params[:commit].nil? || @question.question_type_changed?
  end

  # Lida com a ação de adicionar alternativa.
  def handle_add_alternative_action
    append_empty_option
    save_without_validation_and_redirect
  end

  # Lida com a mudança de tipo de questão.
  def handle_type_change
    ensure_content_consistency
    save_without_validation_and_redirect('Tipo de questão atualizado.')
  end

  # Executa salvamento padrão com validação.
  def perform_standard_save
    @question.content = [] if @question.question_type == 'text'

    if @question.save
      redirect_to edit_template_path(@template), notice: 'template alterado com sucesso'
    else
      redirect_to edit_template_path(@template), alert: @question.errors.full_messages.join(', ')
    end
  end

  # Adiciona string vazia ao array de conteúdo.
  def append_empty_option
    @question.content ||= []
    @question.content << ""
  end

  # Salva sem validação e redireciona (usado para interações dinâmicas).
  def save_without_validation_and_redirect(msg = nil)
    @question.save(validate: false)
    redirect_opts = {}
    redirect_opts[:notice] = msg if msg
    redirect_to edit_template_path(@template), redirect_opts
  end

  # Garante consistência do conteúdo ao mudar tipo.
  def ensure_content_consistency
    case @question.question_type
    when 'text'
      @question.content = []
    when *CHOICE_TYPES
      @question.content = [''] if @question.content.blank?
    end
  end
end