require 'rails_helper'

# Testes de integração para autenticação de usuários.
#
# Cobre login, logout e cenários de erro de autenticação.
RSpec.describe "Autenticacao", type: :request do
  let(:password) { 'senha123' }
  let(:aluno) { Usuario.create!(nome: 'Aluno', email: 'aluno@test.com', usuario: 'aluno', password: password, ocupacao: :discente, status: true, matricula: '123') }
  let(:admin) { Usuario.create!(nome: 'Admin', email: 'admin@test.com', usuario: 'admin', password: password, ocupacao: :admin, status: true, matricula: '999') }

  # Teste de acesso à página de login.
  describe "GET /new (Página de Login)" do
    it "retorna sucesso" do
      get login_path 
      expect(response).to have_http_status(:success)
    end
  end

  # Teste do processo de login (POST).
  describe "POST /create (Fazer Login)" do
    
    # Cenário de sucesso.
    context "Caminho Feliz" do
      it "autentica admin e redireciona para painel" do
        post login_path, params: { email: admin.email, password: password }
        
        expect(response).to redirect_to(admin_gerenciamento_path)
        expect(flash[:notice]).to include("Bem-vindo")
        expect(session[:usuario_id]).to eq(admin.id)
      end

      it "autentica aluno e redireciona para root" do
        post login_path, params: { email: aluno.email, password: password }
        
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to include("Login realizado")
      end
    end

    # Cenário de falha (credenciais inválidas ou erros de sistema).
    context "Quando ocorre AuthenticationError" do
      before do
        allow(Usuario).to receive(:authenticate).and_raise(AuthenticationError, "Usuário ou senha inválidos")
      end

      it "captura o erro e redireciona para login com alerta" do
        post login_path, params: { email: 'errado', password: 'errado' }

        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq("Usuário ou senha inválidos")
      end
    end
  end

  # Teste de logout.
  describe "DELETE /destroy (Logout)" do
    it "reseta sessão, remove cookies e redireciona" do
      post login_path, params: { email: aluno.email, password: password }
      
      cookies[:auth_token] = "token_teste"

      delete logout_path

      expect(response).to redirect_to(login_path)
      expect(flash[:notice]).to eq("Deslogado com sucesso.")
      
      expect(session[:usuario_id]).to be_nil
      
      expect(cookies[:auth_token]).to be_blank
    end
  end
end