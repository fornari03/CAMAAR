require 'rails_helper'

RSpec.describe "Homes", type: :request do
  let(:password) { 'password' }
  
  let(:aluno) { 
    Usuario.create!(
      nome: 'Aluno Teste', 
      email: 'aluno@home.com', 
      matricula: '123456', 
      usuario: '123456', 
      password: password, 
      ocupacao: :discente, 
      status: true
    ) 
  }

  let(:admin) { 
    Usuario.create!(
      nome: 'Admin Teste', 
      email: 'admin@home.com', 
      matricula: '999999', 
      usuario: 'admin', 
      password: password, 
      ocupacao: :admin,
      status: true
    ) 
  }

  describe "GET /index" do

    context "quando logado como Discente" do
      before do
        post login_path, params: { email: aluno.email, password: password }
      end

      it "acessa a home e carrega pendências" do
        get home_path
        expect(response).to have_http_status(:success)
        
        expect(assigns(:pendencias)).to_not be_nil 
      end
    end

    context "quando logado como Admin" do
      before do
        post login_path, params: { email: admin.email, password: password }
      end

      it "acessa a home sem erros (caminho de admin)" do
        get home_path
        expect(response).to have_http_status(:success)
      end
    end

    context "sem estar logado" do
      it "não quebra a aplicação (redireciona ou falha autenticação)" do
        get home_path
        expect(response.status).to be_in([200, 302]) 
      end
    end

  end
end