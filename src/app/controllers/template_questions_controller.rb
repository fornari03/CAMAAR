class TemplateQuestionsController < ApplicationController
  before_action :set_template
  before_action :set_question, only: %i[update destroy add_alternative]

  CHOICE_TYPES = %w[radio checkbox].freeze

  def create
    @template.template_questions.create(
      title: "Nova Questão",
      question_type: "text",
      content: []
    )
    redirect_to edit_template_path(@template), notice: 'Questão adicionada.'
  end

  def update
    prepare_attributes

    return handle_add_alternative_action if adding_alternative_button?

    if type_changed_or_autosave?
      return handle_type_change
    end

    perform_standard_save
  end

  def destroy
    if @template.template_questions.count <= 1
      redirect_to edit_template_path(@template), alert: 'não é possível salvar template sem questões'
    else
      @question.destroy
      redirect_to edit_template_path(@template), notice: 'template alterado com sucesso'
    end
  end

  def add_alternative
    append_empty_option
    save_without_validation_and_redirect
  end

  private

  def set_template
    @template = Template.find(params[:template_id])
  end

  def set_question
    @question = @template.template_questions.find(params[:id])
  end

  def question_params
    params.require(:template_question).permit(:title, :question_type)
  end

  def prepare_attributes
    @question.content = params[:alternatives] if params[:alternatives]
    @question.assign_attributes(question_params)
  end

  def adding_alternative_button?
    params[:commit] == "Adicionar Alternativa"
  end

  def type_changed_or_autosave?
    params[:commit].nil? || @question.question_type_changed?
  end

  def handle_add_alternative_action
    append_empty_option
    save_without_validation_and_redirect
  end

  def handle_type_change
    ensure_content_consistency
    save_without_validation_and_redirect('Tipo de questão atualizado.')
  end

  def perform_standard_save
    @question.content = [] if @question.question_type == 'text'

    if @question.save
      redirect_to edit_template_path(@template), notice: 'template alterado com sucesso'
    else
      redirect_to edit_template_path(@template), alert: @question.errors.full_messages.join(', ')
    end
  end

  def append_empty_option
    @question.content ||= []
    @question.content << ""
  end

  def save_without_validation_and_redirect(msg = nil)
    @question.save(validate: false)
    redirect_opts = {}
    redirect_opts[:notice] = msg if msg
    redirect_to edit_template_path(@template), redirect_opts
  end

  def ensure_content_consistency
    case @question.question_type
    when 'text'
      @question.content = []
    when *CHOICE_TYPES
      @question.content = [''] if @question.content.blank?
    end
  end
end