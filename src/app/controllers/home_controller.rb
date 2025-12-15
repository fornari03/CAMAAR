class HomeController < ApplicationController
  before_action :authenticate_usuario

  def index
    return load_discente_dashboard if current_usuario.discente?
    return load_admin_dashboard    if current_usuario.admin?
  end

  private

  def load_discente_dashboard
    @pendencias = current_usuario.pendencias
    @respondidos = fetch_forms_respondidos
  end

  def load_admin_dashboard
  end

  def fetch_forms_respondidos
    current_usuario.respostas
                   .where.not(data_submissao: nil)
                   .includes(:formulario)
                   .map(&:formulario)
  end
end