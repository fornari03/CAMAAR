require 'csv'

class ResultadosController < ApplicationController
  before_action :authorize_admin

  def index
    # List all forms for admin to see results status
    @formularios = Formulario.all.includes(:turma, :respostas)
  end

  def show
    @formulario = Formulario.find(params[:id])
    @respostas = @formulario.respostas.includes(resposta_items: [:questao, :opcao_escolhida])

    respond_to do |format|
      format.html
      format.csv do
        send_data generate_csv(@formulario, @respostas), 
                  filename: "avaliacao_#{@formulario.id}_#{Date.today}.csv"
      end
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to resultados_path, alert: "Formulário não encontrado"
  end

  private

  def authorize_admin
    redirect_to root_path, alert: "Acesso restrito." unless current_usuario && current_usuario.admin?
  end

  def generate_csv(formulario, respostas)
    CSV.generate(headers: true) do |csv|
      questions = formulario.template.questoes.order(:id)
      
      # Header
      header = ["Timestamp", "Turma"] + questions.map(&:enunciado)
      csv << header

      # Rows
      respostas.each do |resposta|
        row = [resposta.data_submissao, formulario.turma.codigo]
        
        questions.each do |question|
          item = resposta.resposta_items.find_by(questao: question)
          row << (item ? (item.texto_resposta.presence || item.opcao_escolhida&.texto_opcao) : "")
        end
        
        csv << row
      end
    end
  end
end
