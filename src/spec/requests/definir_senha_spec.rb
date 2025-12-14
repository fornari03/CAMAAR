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
  
  let(:token) { usuario_pendente.signed_id(purpose: :definir_senha) }

  describe "GET /definir_senha" do
    context "com token válido" do
      it "acessa a página de definição de senha com sucesso" do
        get definir_senha_path(token: token)
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Nova Senha")
      end
    end

    context "sem token na URL" do
      it "redireciona com alerta de token ausente" do
        get definir_senha_path(token: "")
        
        expect(response).to redirect_to(login_path)
        follow_redirect!
        expect(flash[:alert]).to include("Link inválido (token ausente)")
      end
    end

    context "com token inválido ou expirado" do
      it "redireciona para login com alerta" do
        get definir_senha_path(token: "token_falso_123")
        
        expect(response).to redirect_to(login_path)
        follow_redirect!
        expect(flash[:alert]).to include("Link inválido ou expirado")
      end
    end

    context "quando o usuário já está ativo" do
      before { usuario_pendente.update!(status: true) }

      it "redireciona avisando que já está ativo" do
        get definir_senha_path(token: token)
        
        expect(response).to redirect_to(login_path)
        follow_redirect!
        expect(flash[:notice]).to include("Você já está ativo")
      end
    end

    context "quando um Admin já está logado" do
      let(:admin) { Usuario.create!(nome: "Admin", email: "adm@t.com", usuario: "admin", matricula: "000", ocupacao: :admin, status: true, password: "123", password_confirmation: "123") }

      it "desloga o admin e mostra a página de definição do usuário novo" do
        post login_path, params: { email: admin.email, password: "123" }
        expect(session[:usuario_id]).to eq(admin.id)

        get definir_senha_path(token: token)

        expect(session[:usuario_id]).to be_nil
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PATCH /definir_senha (create)" do
    context "Caminho Feliz" do
      it "atualiza a senha, ativa o usuário e redireciona" do
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
        expect(flash[:notice]).to include("Senha definida com sucesso")
      end
    end

    context "com token inválido no envio" do
      it "redireciona para login" do
        patch definir_senha_path(token: "token_falso"), params: {
          usuario: { password: "123", password_confirmation: "123" }
        }
        
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to include("Link inválido ou expirado")
      end
    end

    context "com campos de senha em branco" do
      it "renderiza erro de campos obrigatórios" do
        patch definir_senha_path(token: token), params: {
          usuario: { password: "", password_confirmation: "" }
        }
        
        expect(response).to have_http_status(:unprocessable_content)
        expect(flash.now[:alert]).to include("Todos os campos devem ser preenchidos")
        expect(response).to render_template(:new)
      end
    end

    context "Erros de Validação" do
      it "exibe erro quando senhas não conferem" do
        patch definir_senha_path(token: token), params: {
          usuario: {
            password: "SenhaA",
            password_confirmation: "SenhaB"
          }
        }

        expect(response).to have_http_status(:unprocessable_content)
        expect(flash.now[:alert]).to include("As senhas não conferem")
      end

      it "exibe erros genéricos do model (ex: validação customizada falhando)" do
        allow_any_instance_of(Usuario).to receive(:update).and_return(false)
        allow_any_instance_of(Usuario).to receive_message_chain(:errors, :[], :present?).and_return(false)
        allow_any_instance_of(Usuario).to receive_message_chain(:errors, :full_messages, :to_sentence).and_return("Erro Genérico do Model")

        patch definir_senha_path(token: token), params: {
          usuario: { password: "123", password_confirmation: "123" }
        }

        expect(response).to have_http_status(:unprocessable_content)
        expect(flash.now[:alert]).to eq("Erro Genérico do Model")
      end
    end
  end
end