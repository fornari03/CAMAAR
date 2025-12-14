require 'rails_helper'

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

  describe "GET /admin/gerenciamento" do
    it "returns http success" do
      get "/admin/gerenciamento"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /admin/gerenciamento/importar_dados" do
    
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