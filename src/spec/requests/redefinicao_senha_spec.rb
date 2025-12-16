require 'rails_helper'

# Testes de integração para redefinição de senha (esqueci minha senha).
#
# Cobre solicitação de token e alteração de senha.
RSpec.describe "RedefinicaoSenha", type: :request do
  let!(:usuario) { Usuario.create!(nome: "User", email: "teste@email.com", usuario: "user", matricula: "123", ocupacao: :discente, status: true, password: "oldPass", password_confirmation: "oldPass") }
  
  let!(:usuario_pendente) { Usuario.create!(nome: "Pendente", email: "pendente@email.com", usuario: "pendente", matricula: "456", ocupacao: :discente, status: false, password: "temp", password_confirmation: "temp") }

  # Teste de solicitação de reset (Esqueci Senha).
  describe "POST /esqueci_senha" do
    
    # Sucesso.
    context "com e-mail válido e usuário ativo" do
      it "envia e-mail e redireciona para login" do
        expect {
          post esqueci_senha_path, params: { email: usuario.email }
        }.to change { ActionMailer::Base.deliveries.count }.by(1)

        expect(response).to redirect_to(login_path)
        follow_redirect!
        expect(response.body).to include("Se este e-mail estiver cadastrado")
      end
    end

    # Usuário inativo.
    context "com usuário inativo (status false)" do
      it "impede o reset e avisa que precisa definir a senha primeiro" do
        expect {
          post esqueci_senha_path, params: { email: usuario_pendente.email }
        }.not_to change { ActionMailer::Base.deliveries.count }

        expect(response).to redirect_to(login_path)
        follow_redirect!
        expect(flash[:alert]).to include("Você ainda não definiu sua senha")
      end
    end

    # Email inexistente.
    context "com e-mail não cadastrado" do
      it "não envia e-mail mas mostra mensagem de sucesso (segurança)" do
        expect {
          post esqueci_senha_path, params: { email: "inexistente@email.com" }
        }.not_to have_enqueued_mail(UserMailer, :redefinicao_senha)

        expect(response).to redirect_to(login_path)
        follow_redirect!
        expect(response.body).to include("Se este e-mail estiver cadastrado")
      end
    end

    # Validacao.
    context "com campo vazio" do
      it "redireciona para login com erro" do
        post esqueci_senha_path, params: { email: "" }
        
        expect(response).to redirect_to(login_path)
        follow_redirect!
        expect(response.body).to include("O campo de e-mail não pode estar vazio.")
      end
    end
  end

  # Teste de acesso à página de edição de senha.
  describe "GET /redefinir_senha/edit" do
    let(:token) { usuario.signed_id(purpose: :redefinir_senha) }

    context "com token válido" do
      it "acessa a página de redefinição com sucesso" do
        get edit_redefinir_senha_path(token: token)
        
        expect(response).to have_http_status(:success)
        expect(assigns(:usuario)).to eq(usuario)
      end
    end

    context "com token inválido ou expirado" do
      it "redireciona para login com alerta" do
        get edit_redefinir_senha_path(token: "token_invalido_123")
        
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to include("Link inválido ou expirado")
      end
    end
  end

  # Teste de submissão da nova senha.
  describe "PATCH /redefinir_senha" do
    let(:token) { usuario.signed_id(purpose: :redefinir_senha) }

    context "com token válido e senhas iguais" do
      it "atualiza a senha e redireciona para login" do
        patch redefinir_senha_path(token: token), params: {
          usuario: { password: "NewPass123", password_confirmation: "NewPass123" }
        }

        usuario.reload
        expect(usuario.authenticate("NewPass123")).to be_truthy
        expect(response).to redirect_to(login_path)
        expect(flash[:notice]).to include("Senha redefinida com sucesso")
      end
    end

    context "com senhas diferentes" do
      it "não atualiza e mostra erro" do
        patch redefinir_senha_path(token: token), params: {
          usuario: { password: "123", password_confirmation: "456" }
        }

        expect(response).to have_http_status(:unprocessable_content)
        expect(usuario.reload.authenticate("oldPass")).to be_truthy 
      end
    end

    context "com token inválido" do
      it "redireciona para login com erro" do
        patch redefinir_senha_path(token: "token_fake"), params: {
          usuario: { password: "123", password_confirmation: "123" }
        }
        
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to include("Link inválido")
      end
    end
  end
end