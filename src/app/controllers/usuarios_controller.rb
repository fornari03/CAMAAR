class UsuariosController < ApplicationController
  # Antes de show, edit, update e destroy, carrega o @usuario
  before_action :set_usuario, only: %i[show edit update destroy]
  #before_action :authenticate_admin

  # GET /usuarios
  def index
    @usuarios = Usuario.all
  end

  # GET /usuarios/:id
  def show
    # @usuario já foi carregado pelo set_usuario
  end

  # GET /usuarios/new
  def new
    @usuario = Usuario.new
  end

  # POST /usuarios
  def create
    @usuario = Usuario.new(usuario_params)

    if @usuario.save
      redirect_to @usuario, notice: "Usuário criado com sucesso."
    else
      render :new, status: :unprocessable_content
    end
  end

  # GET /usuarios/:id/edit
  def edit
    # @usuario já foi carregado
  end

  # PATCH/PUT /usuarios/:id
  def update
    if @usuario.update(usuario_params)
      redirect_to @usuario, notice: "Usuário atualizado com sucesso."
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /usuarios/:id
  def destroy
    @usuario.destroy
    redirect_to usuarios_url, notice: "Usuário removido com sucesso."
  end
  def redefinir_senha
  end

  private

  # Carrega um usuário pelo id da URL
  def set_usuario
    @usuario = Usuario.find(params[:id])
  end

  # Strong parameters: só permite esses campos virem do form
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
