# spec/controllers/password_controller_spec.rb
require "rails_helper"

RSpec.describe PasswordController, type: :controller do
  render_views

  # ---------- FORGOT ----------

  describe "GET #new_forgot" do
    it "renderiza o template new_forgot com sucesso" do
      get :new_forgot

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:new_forgot)
    end
  end

  describe "POST #forgot" do
    it "quando o email está em branco, renderiza new_forgot com erro" do
      stub_const("EmailService", Class.new) unless defined?(EmailService)

      post :forgot, params: { email: "" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(:new_forgot)
      expect(flash[:alert]).to eq("Você precisa informar um e-mail.")
    end

    it "quando o usuário existe e envio do email é bem-sucedido, redireciona para login com notice" do
      stub_const("EmailService", Class.new) unless defined?(EmailService)

      usuario = instance_double("Usuario")
      allow(Usuario).to receive(:find_by).with(email: "user@example.com").and_return(usuario)
      allow(EmailService).to receive(:send_password_reset_email)
        .with(usuario)
        .and_return({ success: true })

      post :forgot, params: { email: "user@example.com" }

      expect(EmailService).to have_received(:send_password_reset_email).with(usuario)
      expect(response).to redirect_to(login_path)
      expect(flash[:notice]).to eq("Enviamos um email com instruções para redefinir sua senha.")
    end

    it "quando o usuário existe e ocorre erro ao enviar o email, renderiza new_forgot com status 500" do
      stub_const("EmailService", Class.new) unless defined?(EmailService)

      usuario = instance_double("Usuario")
      allow(Usuario).to receive(:find_by).with(email: "user@example.com").and_return(usuario)
      allow(EmailService).to receive(:send_password_reset_email)
        .with(usuario)
        .and_return({ success: false })

      post :forgot, params: { email: "user@example.com" }

      expect(EmailService).to have_received(:send_password_reset_email).with(usuario)
      expect(response).to have_http_status(:internal_server_error)
      expect(response).to render_template(:new_forgot)
      expect(flash[:alert]).to eq("Ocorreu um erro ao enviar o email. Tente novamente mais tarde.")
    end

    it "quando o usuário NÃO existe, redireciona para login com mensagem genérica" do
      stub_const("EmailService", Class.new) unless defined?(EmailService)

      allow(Usuario).to receive(:find_by).with(email: "nao_existe@example.com").and_return(nil)
      expect(EmailService).not_to receive(:send_password_reset_email)

      post :forgot, params: { email: "nao_existe@example.com" }

      expect(response).to redirect_to(login_path)
      expect(flash[:notice]).to eq(
        "Se o email estiver cadastrado, você receberá instruções para redefinir sua senha."
      )
    end
  end

  # ---------- RESET ----------

  describe "GET #new_reset" do
    it "renderiza o template new_reset com sucesso" do
      get :new_reset, params: { email: "user@example.com" }

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:new_reset)
    end
  end

  describe "POST #reset" do
    it "quando algum campo está em branco, renderiza new_reset com erro" do
      post :reset, params: {
        email: "",
        password: "",
        password_confirmation: ""
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(:new_reset)
      expect(flash[:alert]).to eq("Todos os campos são obrigatórios.")
    end

    it "quando as senhas não coincidem, renderiza new_reset com erro" do
      post :reset, params: {
        email: "user@example.com",
        password: "NovaSenha123",
        password_confirmation: "OutraSenha"
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(:new_reset)
      expect(flash[:alert]).to eq("As senhas não coincidem.")
    end

    it "quando o usuário não é encontrado, renderiza new_reset com 404" do
      allow(Usuario).to receive(:find_by).with(email: "nao_existe@example.com").and_return(nil)

      post :reset, params: {
        email: "nao_existe@example.com",
        password: "NovaSenha123",
        password_confirmation: "NovaSenha123"
      }

      expect(response).to have_http_status(:not_found)
      expect(response).to render_template(:new_reset)
      expect(flash[:alert]).to eq("Usuário não encontrado.")
    end

    it "quando o usuário existe e a atualização da senha é bem-sucedida, redireciona para login" do
      usuario = instance_double("Usuario")
      allow(Usuario).to receive(:find_by).with(email: "user@example.com").and_return(usuario)
      allow(usuario).to receive(:update).and_return(true)

      post :reset, params: {
        email: "user@example.com",
        password: "NovaSenha123",
        password_confirmation: "NovaSenha123"
      }

      expect(usuario).to have_received(:update)
      expect(response).to redirect_to(login_path)
      expect(flash[:notice]).to eq("Senha redefinida com sucesso. Agora você já pode fazer login.")
    end

    it "quando o usuário existe e a atualização da senha falha, renderiza new_reset com erro" do
      usuario = instance_double("Usuario")
      allow(Usuario).to receive(:find_by).with(email: "user@example.com").and_return(usuario)
      allow(usuario).to receive(:update).and_return(false)
      allow(usuario).to receive_message_chain(:errors, :full_messages)
        .and_return(["Erro ao salvar"])

      post :reset, params: {
        email: "user@example.com",
        password: "NovaSenha123",
        password_confirmation: "NovaSenha123"
      }

      expect(usuario).to have_received(:update)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(:new_reset)
      expect(flash[:alert]).to eq("Erro ao redefinir senha.")
    end
  end
end
