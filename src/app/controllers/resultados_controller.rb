require 'csv'

class ResultadosController < ApplicationController
  before_action :authorize_admin

  def index
    # List all forms for admin to see results status
    @formularios = Formulario.all.includes(:turma, :respostas)
  end

  def show
    @formulario = Formulario.find(params[:id])
    @respostas = @formulario.respostas.where.not(data_submissao: nil).includes(resposta_items: [:questao, :opcao_escolhida])

    respond_to do |format|
      format.html
      format.csv do
        if @respostas.empty?
          redirect_to resultado_path(@formulario), alert: "Não é possível gerar um relatório, pois não há respostas."
        else
          filename = "relatorio_#{@formulario.titulo_envio.parameterize.underscore}.csv"
          puts "NOME DO ARQUIVO GERADO: #{filename}"
          send_data generate_csv(@formulario, @respostas), filename: filename
        end
      end
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to formularios_path, alert: "Formulário não encontrado"
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
