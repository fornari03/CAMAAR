require 'rails_helper'

RSpec.describe ResultadosController, type: :controller do
  let(:admin) { Usuario.create!(nome: 'Admin', email: 'admin@test.com', usuario: 'admin', password: 'p', ocupacao: :admin, status: true, matricula: '9999') }
  let(:docente) { Usuario.create!(nome: 'Doc', email: 'doc@test.com', usuario: 'doc', password: 'p', ocupacao: :docente, status: true, matricula: '5678') }
  let(:materia) { Materia.create!(nome: 'Mat', codigo: 'M1') }
  let(:turma) { Turma.create!(codigo: 'T1', semestre: '2025.1', horario: '10h', materia: materia, docente: docente) }
  let(:template) { Template.create!(titulo: 'T', participantes: 'alunos', criador: docente, name: 'Template') }
  let(:formulario) { Formulario.create!(titulo_envio: 'F1', data_criacao: Time.now, template: template, turma: turma) }

  before do
    session[:usuario_id] = admin.id # Login as admin
  end

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show (CSV export)" do
    it "returns csv format" do
      get :show, params: { id: formulario.id, format: :csv }
      expect(response.content_type).to include("text/csv")
    end

    it "includes headers in CSV" do
      Questao.create!(enunciado: 'Q1', tipo: 0, template: template)
      get :show, params: { id: formulario.id, format: :csv }
      expect(response.body).to include("Q1")
    end
  end
end
