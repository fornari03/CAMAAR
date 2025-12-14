require 'csv'

class ResultadosController < ApplicationController
  before_action :authorize_admin
  before_action :set_formulario, only: :show
  before_action :load_respostas, only: :show

  def index
    @formularios = Formulario.all.includes(:turma, :respostas)
  end

  def show
    respond_to do |format|
      format.html
      format.csv { handle_csv_export }
    end
  end

  private

  def authorize_admin
    redirect_to root_path, alert: "Acesso restrito." unless current_usuario&.admin?
  end

  def set_formulario
    @formulario = Formulario.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to formularios_path, alert: "Formulário não encontrado"
  end

  def load_respostas
    @respostas = @formulario.respostas
                            .where.not(data_submissao: nil)
                            .includes(resposta_items: %i[questao opcao_escolhida])
  end

  def handle_csv_export
    if @respostas.empty?
      redirect_to resultado_path(@formulario), alert: "Não é possível gerar um relatório, pois não há respostas."
    else
      send_data generate_csv_content, filename: csv_filename
    end
  end

  def csv_filename
    "relatorio_#{@formulario.titulo_envio.parameterize.underscore}.csv"
  end

  def generate_csv_content
    questions = @formulario.template.questoes.order(:id)

    CSV.generate(headers: true) do |csv|
      csv << build_csv_header(questions)
      
      @respostas.each do |resposta|
        csv << build_csv_row(resposta, questions)
      end
    end
  end

  def build_csv_header(questions)
    ["Timestamp", "Turma"] + questions.map(&:enunciado)
  end

  def build_csv_row(resposta, questions)
    base_data = [resposta.data_submissao, @formulario.turma.codigo]
    
    answers_data = questions.map do |question|
      extract_answer_value(resposta, question)
    end
    
    base_data + answers_data
  end

  def extract_answer_value(resposta, question)
    item = resposta.resposta_items.find { |i| i.questao_id == question.id }
    return "" unless item

    item.texto_resposta.presence || item.opcao_escolhida&.texto_opcao
  end
end