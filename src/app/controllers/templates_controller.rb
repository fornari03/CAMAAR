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
    @template.criador = current_usuario # Assuming current_usuario is available
    # If current_usuario is nil (e.g. in tests without auth), we might need a fallback or ensure auth is mocked.
    # For now, we assume auth is handled or we might need to relax the constraint if no user.
    # But schema says null: false.
    
    if @template.save
      redirect_to edit_template_path(@template), notice: 'Template criado com sucesso.'
    else
      flash.now[:alert] = 'Nome não pode ficar em branco'
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
