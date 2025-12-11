require 'rails_helper'

RSpec.describe "Homes", type: :request do
  let(:usuario) { 
    Usuario.create!(
      nome: 'Teste', 
      email: 'teste@home.com', 
      matricula: '123456', 
      usuario: '123456', 
      password: 'password', 
      ocupacao: :discente, 
      status: true
    ) 
  }

  before do
    post login_path, params: { email: usuario.email, password: usuario.password }
  end

  describe "GET /index" do
    it "returns http success" do
      get home_path
      expect(response).to have_http_status(:success)
    end
  end
end