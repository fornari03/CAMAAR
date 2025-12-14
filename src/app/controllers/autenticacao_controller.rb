class AutenticacaoController < ApplicationController
  skip_before_action :require_login, only: [:new, :create], raise: false
  layout "auth"

  def new
    # Renderiza a página de login
  end

  def create
    user = Usuario.authenticate(params[:email], params[:password])

    session[:usuario_id] = user.id

    if user.admin?
      redirect_to admin_gerenciamento_path, notice: "Bem-vindo, Administrador!"
    else
      redirect_to root_path, notice: "Login realizado com sucesso!"
    end

  rescue AuthenticationError => e
    redirect_to login_path, alert: e.message
  end

  def destroy
    reset_session
    
    cookies.delete(:auth_token) if cookies[:auth_token]
    
    redirect_to login_path, notice: "Deslogado com sucesso."
  end
end