class FormulariosController < ApplicationController
  before_action :require_login
  before_action :authorize_admin, only: [:new, :create]

  def index
    @templates = Template.all
    @turmas = Turma.includes(:materia).all
    @formularios = Formulario.all.includes(:template, :turma)
  end

  def new
    @templates = Template.all
    @turmas = Turma.includes(:materia).all
  end

  def show
    @formulario = Formulario.find(params[:id])
  end

  def create
    turmas_ids = params[:turma_ids] || []
    template_id = params[:template_id]
    data_encerramento = params[:data_encerramento]

    if template_id.blank?
      redirect_to new_formulario_path, alert: "É necessário selecionar um template"
      return
    end

    if turmas_ids.empty?
      redirect_to new_formulario_path, alert: "É necessário selecionar pelo menos uma turma"
      return
    end

    ActiveRecord::Base.transaction do
      turmas_ids.each do |turma_id|
        Formulario.create!(
          template_id: template_id,
          turma_id: turma_id,
          titulo_envio: Template.find(template_id).titulo,
          data_criacao: Time.current,
          data_encerramento: data_encerramento
        )
      end
    end

    redirect_to formularios_path, notice: "Formulário criado com sucesso e associado a #{turmas_ids.count} turma(s)"
  rescue ActiveRecord::RecordInvalid => e
    redirect_to new_formulario_path, alert: "Erro ao criar formulário: #{e.message}"
  end

  private

  def reload_view_data
    @templates = Template.all
    @turmas = Turma.includes(:materia).all
  end

  def authorize_admin
    redirect_to root_path, alert: "Acesso restrito." unless current_usuario&.admin?
  end
end