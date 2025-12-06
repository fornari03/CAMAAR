class AdminController < ApplicationController
  def importar_dados
    puts "🟢 CHEGOU NO CONTROLLER!"
    begin
      SigaaImporter.call
      puts "🟢 SERVICE EXECUTADO SEM ERROS!"
      flash[:notice] = "Dados importados com sucesso!"
    rescue StandardError => e
      puts "🔴 ERRO NO CONTROLLER: #{e.message}"
      puts e.backtrace.first(5)
      flash[:alert] = e.message
    end
    redirect_back(fallback_location: "/gerenciamento") 
  end
end