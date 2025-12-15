  # Controlador para CRUD de Templates de Avaliação.
class TemplatesController < ApplicationController
  before_action :set_template, only: [:edit, :update, :destroy]

  # Lista templates visíveis.
  #
  # Retorno:
  #   - Renderiza a view :index.
  #
  # Efeitos Colaterais:
  #   - Define @templates com todos os templates visíveis (não ocultos).
  def index
    @templates = Template.all_visible
  end

  # Renderiza o formulário de criação de template.
  #
  # Retorno:
  #   - Renderiza a view :new.
  #
  # Efeitos Colaterais:
  #   - Define @template como uma nova instância vazia.
  def new
    @template = Template.new
  end

  # Cria um novo template e o associa ao usuário logado.
  #
  # Argumentos:
  #   - params[:template] (ActionController::Parameters): Hash contendo os atributos do template.
  #
  # Retorno:
  #   - Redireciona para a página de edição (edit_template_path) se salvo com sucesso.
  #   - Renderiza a view :new com status :unprocessable_content se houver erros de validação.
  #
  # Efeitos Colaterais:
  #   - Tenta inserir um novo registro na tabela 'templates'.
  #   - Define @template com os dados submetidos.
  #   - Define flash[:notice] em caso de sucesso.
  def create
    @template = Template.new(template_params)
    @template.id_criador = session[:usuario_id]
    
    if @template.save
      redirect_to edit_template_path(@template), notice: 'Template criado com sucesso'
    else
      render :new, status: :unprocessable_content
    end
  end

  # Renderiza a página de edição de um template existente.
  #
  # Retorno:
  #   - Renderiza a view :edit.
  #
  # Efeitos Colaterais:
  #   - Define @template via before_action (set_template).
  def edit
    # @template is set by before_action
  end

  # Atualiza os dados de um template existente.
  #
  # Argumentos:
  #   - params[:template] (ActionController::Parameters): Hash contendo novos atributos.
  #
  # Retorno:
  #   - Redireciona para edit_template_path em caso de sucesso.
  #   - Renderiza a view :edit com status :unprocessable_content se houver erros.
  #
  # Efeitos Colaterais:
  #   - Atualiza o registro no banco de dados.
  #   - Define flash[:notice] em caso de sucesso.
  def update
    if @template.update(template_params)
      redirect_to edit_template_path(@template), notice: 'Template atualizado com sucesso.'
    else
      render :edit, status: :unprocessable_content
    end
  end

  # Remove logicamente um template (soft delete).
  #
  # Retorno:
  #   - Redireciona para a lista de templates (templates_path).
  #
  # Efeitos Colaterais:
  #   - Atualiza o atributo 'hidden' do template para true.
  #   - Define flash[:notice].
  def destroy
    @template.update(hidden: true)
    redirect_to templates_path, notice: 'Template deletado com sucesso.'
  end

  private

  # Busca o template pelo ID fornecido na URL.
  #
  # Efeitos Colaterais:
  #   - Define a variável @template.
  #   - Levanta ActiveRecord::RecordNotFound se não existir.
  def set_template
    @template = Template.find(params[:id])
  end

  # Define quais parâmetros são permitidos para criação/edição (Strong Parameters).
  #
  # Retorno:
  #   - (ActionController::Parameters): Hash contendo apenas a chave :titulo permitida.
  def template_params
    params.require(:template).permit(:titulo)
  end
end
