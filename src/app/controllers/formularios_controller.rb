class FormulariosController < ApplicationController
  before_action :require_login
  before_action :authorize_admin, only: [:new, :create]

  def index
    @formularios = Formulario.all.includes(:template, :turma)
  end

  def new
    @templates = Template.all
    @turmas = Turma.includes(:materia).all
  end

  def create
    turmas_ids = params[:turmas] || []
    template_id = params[:template]
    data_encerramento = params[:data_encerramento]

    erro_msg = nil
    
    if template_id.blank?
      erro_msg = "É necessário selecionar um template"
    elsif turmas_ids.empty?
      erro_msg = "É necessário selecionar pelo menos uma turma"
    end

    if erro_msg
      flash.now[:alert] = erro_msg
      @templates = Template.all
      @turmas = Turma.includes(:materia).all
      render :new, status: :unprocessable_entity
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
    flash.now[:alert] = "Erro ao criar formulário: #{e.message}"
    render :new, status: :unprocessable_entity
  end

  private

  def authorize_admin
    redirect_to root_path, alert: "Acesso restrito." unless current_usuario&.admin?
  end
end