require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    before_action :require_login

    def index
      render plain: "Acesso Permitido"
    end
  end

  let(:usuario) { Usuario.create!(nome: 'User', email: 'user@test.com', usuario: 'user', password: 'password', ocupacao: :discente, status: true, matricula: '123') }

  describe "Verificação de Login (:require_login)" do
    
    context "quando o usuário NÃO está logado" do
      it "redireciona para o login com mensagem de alerta" do
        get :index
        
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq("Você precisa estar logado para acessar esta página.")
      end
    end

    context "quando o usuário ESTÁ logado" do
      before do
        session[:usuario_id] = usuario.id
      end

      it "permite o acesso à página" do
        get :index
        
        expect(response).to have_http_status(:success)
        expect(response.body).to eq("Acesso Permitido")
      end
    end
    
  end
end