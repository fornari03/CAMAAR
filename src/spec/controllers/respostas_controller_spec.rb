require 'rails_helper'

RSpec.describe RespostasController, type: :controller do
  let(:aluno) { Usuario.create!(nome: 'Aluno', email: 'aluno@test.com', usuario: 'aluno', password: 'p', ocupacao: :discente, status: true, matricula: '1234') }
  let(:docente) { Usuario.create!(nome: 'Doc', email: 'doc@test.com', usuario: 'doc', password: 'p', ocupacao: :docente, status: true, matricula: '5678') }
  let(:materia) { Materia.create!(nome: 'Mat', codigo: 'M1') }
  let(:turma) { Turma.create!(codigo: 'T1', semestre: '2025.1', horario: '10h', materia: materia, docente: docente) }
  let(:template) { Template.create!(titulo: 'T', participantes: 'alunos', criador: docente, name: 'Template') }
  let(:formulario) { Formulario.create!(titulo_envio: 'F1', data_criacao: Time.now, template: template, turma: turma) }
  
  before do
    session[:usuario_id] = aluno.id # Simulating login
  end

  describe "GET #new" do
    it "returns http success" do
      get :new, params: { formulario_id: formulario.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    let!(:questao) { Questao.create!(enunciado: 'Q', tipo: 0, template: template) }
    
    it "creates a new Resposta" do
      expect {
        post :create, params: { formulario_id: formulario.id, respostas: { questao.id => "Resposta Teste" } }
      }.to change(Resposta, :count).by(1)
    end

    it "redirects to root path on success" do
      post :create, params: { formulario_id: formulario.id, respostas: { questao.id => "Resposta Teste" } }
      expect(response).to redirect_to(root_path)
    end
  end
end
