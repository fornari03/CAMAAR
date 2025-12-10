class HomeController < ApplicationController
  before_action :authenticate_usuario 
  def index
    return unless current_usuario
    
    if current_usuario.discente?
      @pendencias = current_usuario.pendencias
      # Fetch only submitted forms (where data_submissao is not nil)
      @respondidos = current_usuario.respostas.where.not(data_submissao: nil).map(&:formulario)
    elsif current_usuario.admin?
      # Admin dashboard logic could go here
    end
  end
end
