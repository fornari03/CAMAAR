require 'rails_helper'

RSpec.describe "Formularios", type: :request do
  let(:admin) { Usuario.create!(nome: 'Admin', email: 'admin@test.com', matricula: '123', usuario: 'admin', password: 'password', ocupacao: :admin, status: true) }
  let(:aluno) { Usuario.create!(nome: 'Aluno', email: 'aluno@test.com', matricula: '456', usuario: 'aluno', password: 'password', ocupacao: :discente, status: true) }
  
  let(:template) { Template.create!(name: 'Template Teste', titulo: 'Titulo Teste', id_criador: admin.id, participantes: 'todos') }
  let(:materia) { Materia.create!(nome: 'Engenharia de Software', codigo: 'CIC0105') }
  let(:turma) { Turma.create!(codigo: 'TA', semestre: '2024.1', horario: '35T', materia: materia, docente: admin) }
  let(:formulario_existente) { Formulario.create!(titulo_envio: "Form Test", template: template, turma: turma, data_criacao: Time.now) }

  def sign_in(user)
    allow_any_instance_of(ApplicationController).to receive(:current_usuario).and_return(user)
  end

  before do
    sign_in(admin)
  end

  describe "GET /index" do
    it "returns http success" do
      get formularios_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "exibe o formulário corretamente" do
      get formulario_path(formulario_existente)
      expect(response).to have_http_status(:success)
      expect(assigns(:formulario)).to eq(formulario_existente)
    end
  end

  describe "GET /new" do
    it "carrega os dados necessários e retorna sucesso" do
      get new_formulario_path
      
      expect(response).to have_http_status(:success)
      
      expect(assigns(:templates)).not_to be_nil
      expect(assigns(:turmas)).not_to be_nil
    end
  end

  describe "POST /create" do
    before do
       Matricula.create!(usuario: aluno, turma: turma)
    end

    context "Caminho Feliz" do
      it "distributes form to selected turmas" do
        expect {
          post formularios_path, params: { template_id: template.id, turma_ids: [turma.id] }
        }.to change(Formulario, :count).by(1)
         .and change(Resposta, :count).by(1) 

        expect(response).to redirect_to(formularios_path)
        follow_redirect!
        expect(response.body).to include("Formulário distribuído com sucesso")
      end
    end

    context "Caminhos de Validação e Erro (Cobre Imagens 1 e 2)" do
      it "fails if no turmas selected" do
        post formularios_path, params: { template_id: template.id }
        
        expect(response).to redirect_to(new_formulario_path)
        follow_redirect!
        expect(flash[:alert]).to include("Selecione pelo menos uma turma")
      end

      it "fails if no template selected" do
        post formularios_path, params: { turma_ids: [turma.id], template_id: "" }
        
        expect(response).to redirect_to(new_formulario_path)
        follow_redirect!
        expect(flash[:alert]).to include("Selecione um template")
      end

      it "captura erro de banco de dados e redireciona" do
        allow(Formulario).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(Formulario.new))
        
        post formularios_path, params: { template_id: template.id, turma_ids: [turma.id] }
        
        expect(response).to redirect_to(new_formulario_path)
        expect(flash[:alert]).to include("Erro ao distribuir")
      end
    end
  end

  describe "GET /pendentes" do
    before do
      sign_in(aluno)
    end

    context "Quando aluno não tem turmas (Cobre linhas 66-69)" do
      it "mostra mensagem de alerta e lista vazia" do
        aluno.matriculas.destroy_all
        
        get pendentes_formularios_path
        
        expect(response).to have_http_status(:success)
        expect(flash.now[:alert]).to eq("Você não possui turmas cadastradas")
        expect(assigns(:respostas_pendentes)).to be_empty
      end
    end

    context "Quando aluno tem turmas e formulários (Cobre linhas 70-73)" do
      before do
        Matricula.create!(usuario: aluno, turma: turma)
        Resposta.create!(formulario: formulario_existente, participante: aluno, data_submissao: nil)
      end

      it "lista as respostas pendentes corretamente" do
        get pendentes_formularios_path
        
        expect(response).to have_http_status(:success)
        expect(assigns(:respostas_pendentes)).not_to be_empty
        expect(assigns(:respostas_pendentes).first.formulario).to eq(formulario_existente)
      end
    end
  end
end