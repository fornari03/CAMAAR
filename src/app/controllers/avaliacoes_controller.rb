# Controlador responsável por listar as avaliações pendentes do usuário.
class AvaliacoesController < ApplicationController
  # Lista avaliações que o usuário ainda não respondeu.
  #
  # Argumentos:
  #   - Nenhum (usa current_usuario implícito).
  #
  # Retorno:
  #   - (NilClass): Renderiza index.
  #
  # Efeitos Colaterais:
  #   - Define variável @pendencias.
  def index
    @pendencias = current_usuario.pendencias
  end
end
