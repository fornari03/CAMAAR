require 'rails_helper'

RSpec.describe "RedefinicaoSenha", type: :request do
  let!(:usuario) { Usuario.create!(nome: "User", email: "teste@email.com", usuario: "user", matricula: "123", ocupacao: :discente, status: true, password: "oldPass", password_confirmation: "oldPass") }

  describe "POST /esqueci_senha" do
    context "com e-mail válido" do
      it "envia e-mail e redireciona para login" do
        expect {
          post esqueci_senha_path, params: { email: usuario.email }
        }.to change { ActionMailer::Base.deliveries.count }.by(1)

        expect(response).to redirect_to(login_path)
        follow_redirect!
        expect(response.body).to include("Se este e-mail estiver cadastrado")
      end
    end

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

    context "com campo vazio" do
      it "redireciona para login com erro" do
        post esqueci_senha_path, params: { email: "" }
        
        expect(response).to redirect_to(login_path)
        follow_redirect!
        expect(response.body).to include("O campo de e-mail não pode estar vazio.")
      end
    end
  end

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
        expect(usuario.reload.authenticate("oldPass")).to be_truthy # Senha antiga mantida
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