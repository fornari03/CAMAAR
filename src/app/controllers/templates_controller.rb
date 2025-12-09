  class TemplatesController < ApplicationController
  before_action :set_template, only: [:edit, :update, :destroy]

  def index
    @templates = Template.all_visible
  end

  def new
    @template = Template.new
  end

  def create
    @template = Template.new(template_params)
    @template.id_criador = session[:usuario_id]
    
    if @template.save
      redirect_to edit_template_path(@template), notice: 'Template criado com sucesso'
    else
      # flash.now[:alert] = @template.errors.full_messages.join(', ')
      # The test expects "Titulo can't be blank" which is the default Rails message for presence validation
      # But another test expects "Nome do Template não pode ficar em branco".
      # Let's check the feature file `criar_template.feature`.
      # "Nome do Template não pode ficar em branco"
      # And `form_template_creation.feature`: "Titulo can't be blank"
      # We should probably standardize. But for now, let's output the errors.
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # @template is set by before_action
  end

  def update
    if @template.update(template_params)
      redirect_to edit_template_path(@template), notice: 'Template atualizado com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @template.update(hidden: true)
    redirect_to templates_path, notice: 'Template deletado com sucesso.'
  end

  private

  def set_template
    @template = Template.find(params[:id])
  end

  def template_params
    params.require(:template).permit(:titulo)
  end
end
