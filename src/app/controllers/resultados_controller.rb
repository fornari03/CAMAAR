require 'csv'

# Controlador para visualização e exportação de resultados das avaliações.
class ResultadosController < ApplicationController
  before_action :authorize_admin
  before_action :set_formulario, only: :show
  before_action :load_respostas, only: :show

  # Lista todos os formulários e seus resultados.
  #
  # Argumentos:
  #   - Nenhum
  #
  # Retorno:
  #   - (NilClass): Renderiza index.
  #
  # Efeitos Colaterais:
  #   - Define @formularios.
  def index
    @formularios = Formulario.all.includes(:turma, :respostas)
  end

  # Exibe detalhe de um formulário e permite exportação CSV.
  #
  # Argumentos:
  #   - params[:id] (Integer): ID do formulário.
  #   - format (html/csv): Formato da resposta.
  #
  # Retorno:
  #   - (NilClass/CSV): Renderiza show ou envia arquivo.
  #
  # Efeitos Colaterais:
  #   - Instigates file download (CSV).
  def show
    respond_to do |format|
      format.html
      format.csv { handle_csv_export }
    end
  end

  private

  # Garante acesso apenas admins.
  #
  # Efeitos Colaterais:
  #   - Redireciona com alerta.
  def authorize_admin
    redirect_to root_path, alert: "Acesso restrito." unless current_usuario&.admin?
  end

  # Define o formulário.
  #
  # Efeitos Colaterais:
  #   - Define @formulario ou redireciona.
  def set_formulario
    @formulario = Formulario.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to formularios_path, alert: "Formulário não encontrado"
  end

  # Carrega as respostas submetidas para o formulário.
  #
  # Efeitos Colaterais:
  #   - Define @respostas.
  def load_respostas
    @respostas = @formulario.respostas
                            .where.not(data_submissao: nil)
                            .includes(resposta_items: %i[questao opcao_escolhida])
  end

  # Gerencia a exportação CSV.
  #
  # Efeitos Colaterais:
  #   - Envia dados ou redireciona com erro.
  def handle_csv_export
    if @respostas.empty?
      redirect_to resultado_path(@formulario), alert: "Não é possível gerar um relatório, pois não há respostas."
    else
      send_data generate_csv_content, filename: csv_filename
    end
  end

  # Gera o nome do arquivo CSV.
  #
  # Retorno:
  #   - (String): O nome do arquivo.
  def csv_filename
    "relatorio_#{@formulario.titulo_envio.parameterize.underscore}.csv"
  end

  # Gera o conteúdo do CSV.
  #
  # Retorno:
  #   - (String): O conteúdo CSV.
  def generate_csv_content
    questions = @formulario.template.questoes.order(:id)

    CSV.generate(headers: true) do |csv|
      csv << build_csv_header(questions)
      
      @respostas.each do |resposta|
        csv << build_csv_row(resposta, questions)
      end
    end
  end

  # Constrói o cabeçalho do CSV.
  #
  # Argumentos:
  #   - questions: Lista de questões.
  #
  # Retorno:
  #   - (Array): Array de strings do cabeçalho.
  def build_csv_header(questions)
    ["Timestamp", "Turma"] + questions.map(&:enunciado)
  end

  # Constrói uma linha do CSV.
  #
  # Argumentos:
  #   - resposta: A resposta sendo processada.
  #   - questions: Lista de questões.
  #
  # Retorno:
  #   - (Array): Dados da linha.
  def build_csv_row(resposta, questions)
    base_data = [resposta.data_submissao, @formulario.turma.codigo]
    
    answers_data = questions.map do |question|
      extract_answer_value(resposta, question)
    end
    
    base_data + answers_data
  end

  # Extrai valor de uma resposta para uma questão.
  #
  # Retorno:
  #   - (String): O valor da resposta.
  def extract_answer_value(resposta, question)
    item = resposta.resposta_items.find { |i| i.questao_id == question.id }
    return "" unless item

    item.texto_resposta.presence || item.opcao_escolhida&.texto_opcao
  end
end