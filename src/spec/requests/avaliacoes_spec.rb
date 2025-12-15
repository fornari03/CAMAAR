require 'rails_helper'

# Testes de integração para avaliações.
#
# Cobre a listagem de avaliações para o aluno.
RSpec.describe "Avaliacoes", type: :request do
  let(:aluno) { Usuario.create!(nome: 'Aluno', email: 'a@test.com', matricula: '999', usuario: 'aluno', password: 'password', ocupacao: 'discente', status: true) }
  
  before do
    # Stub current_usuario to be the student
    allow_any_instance_of(ApplicationController).to receive(:current_usuario).and_return(aluno)
  end

  # Teste de listagem.
  describe "GET /index" do
    it "returns http success for student" do
      get avaliacoes_path
      expect(response).to have_http_status(:success)
    end
  end
end
