require 'rails_helper'

RSpec.describe "Formularios", type: :request do
  let!(:docente) { Usuario.create!(nome: 'Prof', email: 'prof@test.com', matricula: '111', usuario: 'prof', password: 'password', ocupacao: 'docente', status: true) }
  let!(:turma) { Turma.create!(codigo: 'T1', semestre: '2024.1', horario: '35T', materia: Materia.create!(codigo: 'M1', nome: 'Mat'), docente: docente) }
  let!(:template) { Template.create!(name: 'Template 1', id_criador: docente.id, titulo: 'Titulo', participantes: 'todos') }

  describe "GET /new" do
    it "returns http success" do
      get new_formulario_path
      expect(response).to have_http_status(:success)
    end
  end
  
  describe "GET /index" do
    it "returns http success" do
      get formularios_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    it "distributes form to selected turmas" do
      expect {
        post formularios_path, params: { template_id: template.id, turma_ids: [turma.id] }
      }.to change(Formulario, :count).by(1)
      .and change(Resposta, :count).by(1) # Docente only yet (if turma has no students)

      expect(response).to redirect_to(formularios_path)
      follow_redirect!
      expect(response.body).to include("Formulário distribuído com sucesso")
    end

    it "fails if no turmas selected" do
      post formularios_path, params: { template_id: template.id }
      expect(response).to render_template(:new) # Or redirect with error
      # Assuming implementation might redirect back to new or index
    end
  end
end
