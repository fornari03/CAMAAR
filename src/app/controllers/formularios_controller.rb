class FormulariosController < ApplicationController
  before_action :require_login
  before_action :authorize_admin, only: [:new, :create, :index]

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
      flash[:alert] = "Selecione um template"
      redirect_to new_formulario_path
      return
    end

    if turmas_ids.empty?
      flash[:alert] = "Selecione pelo menos uma turma" 
      redirect_to new_formulario_path
      return
    end

    ActiveRecord::Base.transaction do
      turmas_ids.each do |turma_id|
        turma = Turma.find(turma_id)
        
        form = Formulario.create!(
          template_id: template_id,
          turma_id: turma_id,
          titulo_envio: Template.find(template_id).titulo,
          data_criacao: Time.current,
          data_encerramento: data_encerramento
        )

        turma.matriculas.each do |matricula|
          Resposta.create!(
            formulario: form,
            participante: matricula.usuario,
            data_submissao: nil
          )
        end
      end
    end

    redirect_to formularios_path, notice: "Formulário distribuído com sucesso para #{turmas_ids.count} turmas"
  
  rescue ActiveRecord::RecordInvalid => e
    flash[:alert] = "Erro ao distribuir: #{e.message}"
    redirect_to new_formulario_path
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

  def reload_view_data
    @templates = Template.all
    @turmas = Turma.includes(:materia).all
  end

  def authorize_admin
    redirect_to root_path, alert: "Acesso restrito." unless current_usuario&.admin?
  end
end