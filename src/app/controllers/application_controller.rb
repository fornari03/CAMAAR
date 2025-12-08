class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  helper_method :current_usuario

  def current_usuario
    return @current_usuario if defined?(@current_usuario)

    if session[:usuario_id]
      @current_usuario = Usuario.find_by(id: session[:usuario_id])
    else
      @current_usuario = nil
    end
  end

  def authenticate_usuario
    redirect_to login_path, alert: "Faça login para continuar." unless current_usuario.present?
  end

  def authenticate_admin
    redirect_to login_path, alert: "Acesso negado." unless current_usuario&.admin?
  end
end
