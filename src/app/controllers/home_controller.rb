# Controlador da página inicial. Redireciona usuários baseado no perfil.
class HomeController < ApplicationController
  before_action :authenticate_usuario

  # Renderiza a dashboard apropriada para o usuário logado.
  #
  # Argumentos:
  #   - Nenhum
  #
  # Retorno:
  #   - (NilClass): Renderiza index.
  #
  # Efeitos Colaterais:
  #   - Carrega dados para a dashboard.
  def index
    return load_discente_dashboard if current_usuario.discente?
    return load_admin_dashboard    if current_usuario.admin?
  end

  private

  # Carrega dados para a dashboard do discente.
  #
  # Efeitos Colaterais:
  #   - Define @pendencias e @respondidos.
  def load_discente_dashboard
    @pendencias = current_usuario.pendencias
    @respondidos = fetch_forms_respondidos
  end

  # Carrega dados para a dashboard do administrador.
  #
  # Efeitos Colaterais:
  #   - Nenhum por enquanto.
  def load_admin_dashboard
  end

  # Busca formulários já respondidos pelo usuário.
  #
  # Retorno:
  #   - (Array<Formulario>): Lista de formulários respondidos.
  def fetch_forms_respondidos
    current_usuario.respostas
                   .where.not(data_submissao: nil)
                   .includes(:formulario)
                   .map(&:formulario)
  end
end