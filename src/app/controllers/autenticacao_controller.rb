class AutenticacaoController < ApplicationController
  skip_before_action :require_login, only: %i[new create], raise: false
  layout "auth"

  def new
    # Renderiza a página de login
  end

  def create
    user = Usuario.authenticate(params[:email], params[:password])

    initialize_session(user)
    redirect_based_on_role(user)

  rescue AuthenticationError => e
    handle_auth_failure(e)
  end

  def destroy
    reset_session
    cookies.delete(:auth_token)
    redirect_to login_path, notice: "Deslogado com sucesso."
  end

  private

  def initialize_session(user)
    session[:usuario_id] = user.id
  end

  def redirect_based_on_role(user)
    if user.admin?
      redirect_to admin_gerenciamento_path, notice: "Bem-vindo, Administrador!"
    else
      redirect_to root_path, notice: "Login realizado com sucesso!"
    end
  end

  def handle_auth_failure(exception)
    redirect_to login_path, alert: exception.message
  end
end