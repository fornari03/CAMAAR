class AutenticacaoController < ApplicationController
  skip_before_action :require_login, only: [:new, :create], raise: false
  layout "auth" # Mantendo o layout que configuramos antes

  def new
    # Renderiza a página de login
  end

  def create
    email = params[:email]
    password = params[:password]

    @usuario = Usuario.find_by(email: email)

    if @usuario && @usuario.authenticate(password)
      session[:usuario_id] = @usuario.id

      if @usuario.admin?
        redirect_to admin_gerenciamento_path, notice: "Bem-vindo, Administrador!"
      else
        redirect_to root_path, notice: "Login realizado com sucesso!"
      end

    else
      flash.now[:alert] = "Email ou senha incorretos."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:usuario_id] = nil
    redirect_to login_path, notice: "Deslogado com sucesso."
  end
end