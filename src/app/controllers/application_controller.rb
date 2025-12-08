class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  helper_method :current_usuario

  def current_usuario
    # Dummy implementation for Templates feature development without full Login feature
    @current_usuario ||= Usuario.first || Usuario.create!(
      nome: 'Admin', 
      email: 'admin@test.com', 
      matricula: '123456', 
      usuario: 'admin', 
      password: 'password', 
      ocupacao: :admin, 
      status: true
    )
  end

  def authenticate_usuario
    redirect_to login_path, alert: "Faça login para continuar." unless current_usuario.present?
  end

  def authenticate_admin
    redirect_to root_path, alert: "Acesso negado." unless current_usuario&.admin?
  end
end
