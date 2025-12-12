require 'rails_helper'

RSpec.describe "Formularios", type: :request do
  let(:admin) { Usuario.create!(nome: 'Admin', email: 'admin@test.com', matricula: '123', usuario: 'admin', password: 'password', ocupacao: :admin, status: true) }
  let(:template) { Template.create!(name: 'Template Teste', titulo: 'Titulo Teste', id_criador: admin.id, participantes: 'todos') }
  let(:materia) { Materia.create!(nome: 'Engenharia de Software', codigo: 'CIC0105') }
  let(:turma) { Turma.create!(codigo: 'TA', semestre: '2024.1', horario: '35T', materia: materia, docente: admin) }
  let(:aluno) { Usuario.create!(nome: 'Aluno', email: 'aluno@test.com', matricula: '456', usuario: 'aluno', password: 'password', ocupacao: :discente, status: true) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_usuario).and_return(admin)
  end

  describe "GET /index" do
    it "returns http success" do
      get formularios_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    before do
       Matricula.create!(usuario: aluno, turma: turma)
    end

    it "distributes form to selected turmas" do
      expect {
        post formularios_path, params: { template_id: template.id, turma_ids: [turma.id] }
      }.to change(Formulario, :count).by(1)
       .and change(Resposta, :count).by(1) 

      expect(response).to redirect_to(formularios_path)
      follow_redirect!
      expect(response.body).to include("Formulário distribuído com sucesso")
    end

    it "fails if no turmas selected" do
      post formularios_path, params: { template_id: template.id }
      
      expect(response).to redirect_to(new_formulario_path)
      follow_redirect!
      expect(response.body).to include("Selecione pelo menos uma turma")
    end
  end
end