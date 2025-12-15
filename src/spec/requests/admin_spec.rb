require 'rails_helper'

# Testes de para a área administrativa.
#
# Cobre o acesso ao painel e a funcionalidade de importação de dados.
RSpec.describe "Admins", type: :request do
  let(:admin) { 
    Usuario.create!(
      nome: 'Admin Teste', 
      email: 'admin@teste.com', 
      matricula: '000000', 
      usuario: '000000', 
      password: 'password', 
      ocupacao: :admin, 
      status: true
    ) 
  }

  before do
    post login_path, params: { email: admin.email, password: admin.password }
  end

  # Testes para o painel de gerenciamento.
  describe "GET /admin/gerenciamento" do
    it "returns http success" do
      get "/admin/gerenciamento"
      expect(response).to have_http_status(:success)
    end
  end

  # Testes para a ação de importar dados via POST.
  describe "POST /admin/gerenciamento/importar_dados" do
    
    # Contexto de sucesso na importação.
    context "quando a importação é realizada com sucesso" do
      before do
        expect(SigaaImporter).to receive(:call).once
      end

      it "chama o importer, define flash notice e redireciona" do
        post importar_dados_path 
 
        expect(response).to redirect_to("/admin/gerenciamento")
        
        follow_redirect! 
        expect(flash[:notice]).to eq("Dados importados com sucesso!")
      end
    end

    # Contexto de falha na importação.
    context "quando ocorre um erro durante a importação" do
      before do
        allow(SigaaImporter).to receive(:call).and_raise(StandardError, "Falha na conexão com SIGAA")
      end

      it "captura o erro, define flash alert e redireciona" do
        post importar_dados_path

        expect(response).to redirect_to("/admin/gerenciamento")
        
        follow_redirect!
        expect(flash[:alert]).to eq("Falha na conexão com SIGAA")
      end
    end
  end
end