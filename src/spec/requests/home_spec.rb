require 'rails_helper'

# Testes de integração para a página inicial (Home).
#
# Cobre o acesso à root_path para diferentes tipos de usuário.
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

  # Teste de acesso ao endpoint principal.
  describe "GET /index" do

    # Cenário de Discente.
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

    # Cenário de Admin.
    context "quando logado como Admin" do
      before do
        post login_path, params: { email: admin.email, password: password }
      end

      it "acessa a home sem erros (caminho de admin)" do
        get home_path
        expect(response).to have_http_status(:success)
      end
    end

    # Cenário sem login.
    context "sem estar logado" do
      it "não quebra a aplicação (redireciona ou falha autenticação)" do
        get home_path
        expect(response.status).to be_in([200, 302]) 
      end
    end

  end
end