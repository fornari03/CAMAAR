require 'rails_helper'

RSpec.describe "Admins", type: :request do
  let(:admin) { 
    Usuario.create!(
      nome: 'Admin Teste', 
      email: 'admin@teste.com', 
      matricula: '000000', 
      usuario: '000000', 
      password: 'password', 
      ocupacao: :admin, 
      status: true
    ) 
  }

  describe "GET /admin/gerenciamento" do
    it "returns http success" do
      post login_path, params: { email: admin.email, password: admin.password }
      
      get "/admin/gerenciamento"
      
      expect(response).to have_http_status(:success)
    end
  end
end