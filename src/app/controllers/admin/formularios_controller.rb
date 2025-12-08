class Admin::FormulariosController < ApplicationController
  def index
    @templates = Template.all
    @turmas = Turma.all
  end

  def create
    template = Template.find(params[:template_id])
    turma_ids = params[:turma_ids]

    if turma_ids.blank?
      flash[:alert] = "Selecione pelo menos uma turma"
      redirect_to admin_formularios_path and return
    end

    success_count = 0
    turma_ids.each do |turma_id|
      turma = Turma.find(turma_id)
      turma.distribuir_formulario(template)
      success_count += 1
    end

    flash[:notice] = "Formulário distribuído com sucesso para #{success_count} turmas"
    redirect_to admin_formularios_path
  end
end
