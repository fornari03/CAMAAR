class AdminController < ApplicationController
  def importar_dados
    begin
      SigaaImporter.call
      flash[:notice] = "Dados importados com sucesso!"
    rescue StandardError => e
      flash[:alert] = e.message
    end
    redirect_back(fallback_location: "/gerenciamento") 
  end
end