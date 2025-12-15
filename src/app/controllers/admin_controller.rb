# Controlador responsável pela área administrativa de gerenciamento.
# Requer autenticação de administrador.
class AdminController < ApplicationController
  before_action :authenticate_admin

  # Renderiza a página inicial administrativa.
  #
  # Argumentos:
  #   - Nenhum
  #
  # Retorno:
  #   - (NilClass): Renderiza a view index.
  #
  # Efeitos Colaterais:
  #   - Nenhum.
  def index
  end

  # Ação para importar dados do SIGAA manualmente via interface.
  #
  # Argumentos:
  #   - Nenhum
  #
  # Retorno:
  #   - (NilClass): Redireciona de volta com flash message.
  #
  # Efeitos Colaterais:
  #   - Executa SigaaImporter.call.
  #   - Define flash[:notice] ou flash[:alert].
  def importar_dados
    begin
      SigaaImporter.call
      flash[:notice] = "Dados importados com sucesso!"
    rescue StandardError => e
      flash[:alert] = e.message
    end
    redirect_back(fallback_location: "/admin/gerenciamento") 
  end

  # Renderiza a página de gerenciamento de dados do administrador.
  #
  # Argumentos:
  #   - Nenhum
  #
  # Retorno:
  #   - (NilClass): Renderiza a view gerenciamento.
  #
  # Efeitos Colaterais:
  #   - Define variável de instância @sistema_tem_dados.
  def gerenciamento
    @sistema_tem_dados = Turma.exists?
  end
end
