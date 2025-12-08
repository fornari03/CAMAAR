class AutenticacaoController < ApplicationController
  # tela de login
  def new
    @usuario = Usuario.new
  end

  # processa login
  def create
    usuario_param  = params[:usuario][:usuario]
    password_param = params[:usuario][:password]

    usuario = Usuario.authenticate(usuario_param, password_param)

    # se não levantou erro, login ok
    session[:usuario_id] = usuario.id

    if usuario.admin?
      redirect_to admin_path, notice: "Login de admin realizado com sucesso."
    else
      redirect_to root_path, notice: "Login realizado com sucesso."
    end
  rescue AuthenticationError => e
    # se der erro de usuário/senha, volta pra tela de login com mensagem
    @usuario = Usuario.new(usuario: usuario_param)
    flash.now[:alert] = e.message
    render :new, status: :unauthorized
  end

  # logout
  def destroy
    reset_session
    redirect_to login_path, notice: "Logout realizado com sucesso."
  end
end
