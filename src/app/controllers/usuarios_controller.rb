# Controlador para CRUD de Usuários.
class UsuariosController < ApplicationController
  # Antes de show, edit, update e destroy, carrega o @usuario
  before_action :set_usuario, only: %i[show edit update destroy]
  #before_action :authenticate_admin

  # Lista usuários cadastrados.
  #
  # Retorno:
  #   - Renderiza a view :index.
  #
  # Efeitos Colaterais:
  #   - Define @usuarios com todos os registros.
  def index
    @usuarios = Usuario.all
  end

  # Exibe detalhes do usuário.
  #
  # Argumentos:
  #   - params[:id] (Integer): ID do usuário na URL.
  #
  # Retorno:
  #   - Renderiza a view :show.
  #
  # Efeitos Colaterais:
  #   - Define @usuario via set_usuario.
  def show
    # @usuario já foi carregado pelo set_usuario
  end

  # Renderiza o formulário de cadastro de novo usuário.
  #
  # Retorno:
  #   - Renderiza a view :new.
  #
  # Efeitos Colaterais:
  #   - Define @usuario como uma nova instância vazia.
  def new
    @usuario = Usuario.new
  end

  # Cria um novo usuário no sistema.
  #
  # Argumentos:
  #   - params[:usuario] (ActionController::Parameters): Atributos do usuário.
  #
  # Retorno:
  #   - Redireciona para página do usuário (@usuario) se salvo com sucesso.
  #   - Renderiza a view :new com status :unprocessable_content se houver erros de validação.
  #
  # Efeitos Colaterais:
  #   - Tenta salvar novo registro no DB.
  #   - Define flash[:notice] em sucesso.
  def create
    @usuario = Usuario.new(usuario_params)

    if @usuario.save
      redirect_to @usuario, notice: "Usuário criado com sucesso."
    else
      render :new, status: :unprocessable_content
    end
  end

  # Renderiza o formulário de edição de usuário.
  #
  # Retorno:
  #   - Renderiza a view :edit.
  #
  # Efeitos Colaterais:
  #   - Define @usuario via set_usuario.
  def edit
    # @usuario já foi carregado
  end

  # Atualiza os dados de um usuário existente.
  #
  # Argumentos:
  #   - params[:usuario] (ActionController::Parameters): Novos atributos.
  #
  # Retorno:
  #   - Redireciona para página do usuário (@usuario) se salvo com sucesso.
  #   - Renderiza a view :edit com status :unprocessable_content se houver erros.
  #
  # Efeitos Colaterais:
  #   - Atualiza registro no DB.
  #   - Define flash[:notice] em sucesso.
  def update
    if @usuario.update(usuario_params)
      redirect_to @usuario, notice: "Usuário atualizado com sucesso."
    else
      render :edit, status: :unprocessable_content
    end
  end

  # Remove um usuário do sistema.
  #
  # Retorno:
  #   - Redireciona para a lista de usuários (usuarios_url).
  #
  # Efeitos Colaterais:
  #   - Exclui o registro do DB (destroy).
  #   - Define flash[:notice].
  def destroy
    @usuario.destroy
    redirect_to usuarios_url, notice: "Usuário removido com sucesso."
  end

  # Placeholder para redefinição de senha manual (ainda não implementado completamente).
  def redefinir_senha
  end

  private

  # Carrega um usuário pelo id da URL.
  #
  # Efeitos Colaterais:
  #   - Define @usuario.
  def set_usuario
    @usuario = Usuario.find(params[:id])
  end

  # Strong parameters: só permite esses campos virem do form.
  def usuario_params
    params.require(:usuario).permit(
      :nome,
      :email,
      :matricula,
      :usuario,
      :password,
      :ocupacao,
      :status
    )
  end
end
