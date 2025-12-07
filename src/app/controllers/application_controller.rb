class ApplicationController < ActionController::Base
  helper_method :current_usuario
  def current_usuario
    @current_usuario ||= Usuario.find_by(id: session[:usuario_id])
  end

  def authenticate_usuario
    redirect_to login_path, alert: "Faça login para continuar." unless current_usuario.present?
  end

  def authenticate_admin
    redirect_to root_path, alert: "Acesso negado." unless current_usuario&.admin?
  end
end
