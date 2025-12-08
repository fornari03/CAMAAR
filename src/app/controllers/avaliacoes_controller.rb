class AvaliacoesController < ApplicationController
  def index
    @pendencias = current_usuario.pendencias
  end
end
