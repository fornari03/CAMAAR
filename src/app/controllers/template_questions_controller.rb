class TemplateQuestionsController < ApplicationController
  before_action :set_template
  before_action :set_question, only: [:update, :destroy, :add_alternative]

  def create
    @question = @template.template_questions.create(
      title: "Nova Questão",
      question_type: "text",
      content: []
    )
    redirect_to edit_template_path(@template), notice: 'Questão adicionada.'
  end

  def update
    # Handle alternatives if present
    if params[:alternatives]
      # Filter out empty alternatives if desired, or keep them.
      # The plan says "colete os inputs... serialize".
      # Here we assume params[:alternatives] is an array of strings.
      @question.content = params[:alternatives] # params[:alternatives] is an array from name="alternatives[]"
    end

    # If commit is nil (JS submit) or type is changing, skip validation to allow UI update.
    @question.assign_attributes(question_params)
    type_changing = @question.question_type_changed?
    
    if params[:commit].nil? || type_changing
      @question.save(validate: false)
      
      # Clear content if type changed to text
      if @question.question_type == 'text'
        @question.content = []
        @question.save(validate: false)
      end
      redirect_to edit_template_path(@template), notice: 'Tipo de questão atualizado.'
    else
      # Normal save with validation
      if @question.save
        if @question.question_type == 'text'
          @question.content = []
          @question.save
        end
        redirect_to edit_template_path(@template), notice: 'template alterado com sucesso'
      else
        redirect_to edit_template_path(@template), alert: @question.errors.full_messages.join(', ')
      end
    end
  end

  def destroy
    if @template.template_questions.count <= 1
      redirect_to edit_template_path(@template), alert: 'não é possível salvar template sem questões'
      return
    end

    @question.destroy
    redirect_to edit_template_path(@template), notice: 'template alterado com sucesso'
  end

  def add_alternative
    current_content = @question.content || []
    current_content << "" # Add empty option
    @question.content = current_content
    @question.save(validate: false) # Bypass validation to allow adding empty option
    redirect_to edit_template_path(@template)
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
end
