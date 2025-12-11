require 'rails_helper'

RSpec.describe "DefinicaoSenha", type: :request do
  let!(:usuario_pendente) { 
    Usuario.create!(
      nome: "Novo Aluno", 
      email: "novo@teste.com", 
      usuario: "novo_aluno", 
      matricula: "12345", 
      ocupacao: :discente, 
      status: false, 
      password: "TempPass123!"
    ) 
  }

  describe "GET /definir_senha" do
    context "com token válido" do
      it "acessa a página de definição de senha com sucesso" do
        token = usuario_pendente.signed_id(purpose: :definir_senha)
        
        get definir_senha_path(token: token)
        
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Nova Senha")
      end
    end

    context "com token inválido ou expirado" do
      it "redireciona para login com alerta" do
        get definir_senha_path(token: "token_falso_123")
        
        expect(response).to redirect_to(login_path)
        follow_redirect!
        expect(response.body).to include("Link inválido")
      end
    end

    context "quando um Admin já está logado" do
      let(:admin) { Usuario.create!(nome: "Admin", email: "adm@t.com", usuario: "admin", matricula: "000", ocupacao: :admin, status: true, password: "123", password_confirmation: "123") }

      it "desloga o admin e mostra a página de definição do usuário novo" do
        post login_path, params: { email: admin.email, password: "123" }
        expect(session[:usuario_id]).to eq(admin.id)

        token = usuario_pendente.signed_id(purpose: :definir_senha)
        get definir_senha_path(token: token)

        expect(session[:usuario_id]).to be_nil
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PATCH /definir_senha" do
    let(:token) { usuario_pendente.signed_id(purpose: :definir_senha) }

    context "com senhas válidas" do
      it "atualiza a senha, ativa o usuário e loga" do
        patch definir_senha_path(token: token), params: {
          usuario: {
            password: "NovaSenhaForte123!",
            password_confirmation: "NovaSenhaForte123!"
          }
        }

        usuario_pendente.reload
        expect(usuario_pendente.status).to be_truthy
        expect(usuario_pendente.authenticate("NovaSenhaForte123!")).to be_truthy
        
        expect(response).to redirect_to(login_path)
        expect(session[:usuario_id]).to be_nil
      end
    end

    context "com confirmação de senha incorreta" do
      it "não atualiza e re-renderiza o formulário" do
        patch definir_senha_path(token: token), params: {
          usuario: {
            password: "SenhaA",
            password_confirmation: "SenhaB"
          }
        }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("Defina sua Senha")
        
        usuario_pendente.reload
        expect(usuario_pendente.status).to be_falsey
      end
    end
  end
end