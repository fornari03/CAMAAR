class TemplateQuestionsController < ApplicationController
  before_action :set_template
  before_action :set_question, only: [:update, :destroy, :add_alternative]

  def create
    @question = @template.template_questions.create(
      title: "",
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

    if @question.update(question_params)
      # If question type changed to text, maybe clear content?
      if @question.question_type == 'text'
        @question.content = []
        @question.save
      end
      redirect_to edit_template_path(@template), notice: 'Questão atualizada.'
    else
      redirect_to edit_template_path(@template), alert: 'Erro ao atualizar questão.'
    end
  end

  def destroy
    @question.destroy
    redirect_to edit_template_path(@template), notice: 'Questão removida.'
  end

  def add_alternative
    current_content = @question.content || []
    current_content << "" # Add empty option
    @question.update(content: current_content)
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
