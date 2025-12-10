class HomeController < ApplicationController
  before_action :authenticate_usuario 
  def index
    return unless current_usuario
    
    if current_usuario.discente?
      @pendencias = current_usuario.pendencias
      # Also fetch answered forms if needed for "Formulários Respondidos" section
      @respondidos = current_usuario.respostas.map(&:formulario)
    elsif current_usuario.admin?
      # Admin dashboard logic could go here
    end
  end
end
