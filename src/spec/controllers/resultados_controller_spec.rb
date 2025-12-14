require 'rails_helper'

RSpec.describe ResultadosController, type: :controller do
  let(:admin) { 
    Usuario.create!(
      nome: 'Admin', 
      email: "admin_#{Time.now.to_f}@test.com", 
      usuario: "admin_#{Time.now.to_f}", 
      password: 'p', 
      ocupacao: :admin, 
      status: true, 
      matricula: "ADM#{rand(9999)}"
    ) 
  }
  
  let(:docente) { 
    Usuario.create!(
      nome: 'Doc', 
      email: "doc_#{Time.now.to_f}@test.com", 
      usuario: "doc_#{Time.now.to_f}", 
      password: 'p', 
      ocupacao: :docente, 
      status: true, 
      matricula: "DOC#{rand(9999)}"
    ) 
  }

  let(:materia) { Materia.create!(nome: 'Mat', codigo: "M#{rand(999)}") }
  let(:turma) { Turma.create!(codigo: 'T1', semestre: '2025.1', horario: '10h', materia: materia, docente: docente) }
  let(:template) { Template.create!(titulo: 'T', participantes: 'alunos', id_criador: docente.id, name: 'Template') }
  let(:formulario) { Formulario.create!(titulo_envio: 'F1', data_criacao: Time.now, template: template, turma: turma, data_encerramento: Time.now + 1.day) }

  before do
    session[:usuario_id] = admin.id
  end

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    
    context "quando existem respostas" do
      before do
        aluno = Usuario.create!(
          nome: 'Aluno', 
          email: "aluno_#{Time.now.to_f}@test.com", 
          usuario: "aluno_#{Time.now.to_f}", 
          password: 'p', 
          ocupacao: :discente, 
          status: true, 
          matricula: "A#{rand(9999)}"
        )
        
        Resposta.create!(
          formulario: formulario,
          participante: aluno,
          data_submissao: Time.now
        )
      end

      it "retorna formato csv com sucesso" do
        get :show, params: { id: formulario.id, format: :csv }
        expect(response.content_type).to include("text/csv")
      end

      it "inclui cabeçalhos no CSV" do
        Questao.create!(enunciado: 'Questão Teste', tipo: 0, template: template)
        get :show, params: { id: formulario.id, format: :csv }
        expect(response.body).to include("Questão Teste")
      end
    end

    context "quando NÃO existem respostas (Download CSV)" do
      it "redireciona com alerta" do
        get :show, params: { id: formulario.id, format: :csv }

        expect(response).to redirect_to(resultado_path(formulario))
        expect(flash[:alert]).to eq("Não é possível gerar um relatório, pois não há respostas.")
      end
    end

    context "quando o formulário não é encontrado" do
      it "captura RecordNotFound e redireciona para index de formulários" do
        get :show, params: { id: 999999 }

        expect(response).to redirect_to(formularios_path)
        expect(flash[:alert]).to eq("Formulário não encontrado")
      end
    end
  end
end