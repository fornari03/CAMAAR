class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  helper_method :current_usuario, :logged_in?

  # def current_usuario
  #   # Dummy implementation for Templates feature development without full Login feature
  #   @current_usuario ||= Usuario.first || Usuario.create!(
  #     nome: 'Admin', 
  #     email: 'admin@test.com', 
  #     matricula: '123456', 
  #     usuario: 'admin', 
  #     password: 'password', 
  #     ocupacao: :admin, 
  #     status: true
  #   )

  def current_usuario
    @current_usuario ||= Usuario.find_by(id: session[:usuario_id])
  end

  def authenticate_usuario
    redirect_to login_path, alert: "Faça login para continuar." unless current_usuario.present?
  end

  def authenticate_admin
    redirect_to root_path, alert: "Acesso negado." unless current_usuario&.admin?
  end

  def logged_in?
    current_usuario.present?
  end

  def require_login
    unless logged_in?
      redirect_to login_path, alert: "Você precisa estar logado para acessar esta página."
    end
  end
end
