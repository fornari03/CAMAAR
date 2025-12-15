require 'rails_helper'

# Testes de unidade para TemplateQuestionsController.
#
# Cobre gestão de questões dentro de um template (CRUD, adição de alternativas).
RSpec.describe TemplateQuestionsController, type: :controller do
  let(:admin) { Usuario.create!(nome: 'Admin', email: 'admin@test.com', matricula: '123', usuario: 'admin', password: 'password', ocupacao: :admin, status: true) }
  let(:template) { Template.create!(titulo: 'Test Template', id_criador: admin.id) }
  let!(:question) { TemplateQuestion.create!(template: template, title: 'Questão Original', question_type: 'text', content: []) }
  
  before do
    session[:usuario_id] = admin.id
  end

  # Teste de criação de nova questão.
  describe 'POST #create' do
    it 'creates a new question with defaults and redirects to template edit' do
      expect {
        post :create, params: { template_id: template.id }
      }.to change(TemplateQuestion, :count).by(1)

      question = TemplateQuestion.last
      expect(question.title).to eq("Nova Questão")
      expect(question.question_type).to eq("text")
      expect(response).to redirect_to(edit_template_path(template))
    end
  end

  # Teste de atualização de questão.
  describe 'PATCH #update' do
    
    # Adicionar alternativa.
    context 'Quando clica em Adicionar Alternativa' do
      it 'adiciona uma opção vazia e redireciona' do
        patch :update, params: { 
          template_id: template.id, 
          id: question.id, 
          template_question: { title: 'Q' },
          commit: "Adicionar Alternativa"
        }
        
        question.reload
        expect(question.content).to include("")
        expect(response).to redirect_to(edit_template_path(template))
      end
    end

    # Alterar tipo de questão.
    context 'Mudança de Tipo de Questão' do
      it 'limpa o conteúdo se mudar para TEXTO' do
        question.update!(question_type: 'radio', content: ['A', 'B'])
        
        patch :update, params: {
          template_id: template.id,
          id: question.id,
          template_question: { question_type: 'text' }
        }
        
        question.reload
        expect(question.question_type).to eq('text')
        expect(question.content).to be_empty
        expect(flash[:notice]).to eq('Tipo de questão atualizado.')
      end

      it 'adiciona opção vazia se mudar para RADIO e conteúdo for nulo' do
        question.update!(question_type: 'text', content: nil)

        patch :update, params: {
          template_id: template.id,
          id: question.id,
          template_question: { question_type: 'radio' }
        }

        question.reload
        expect(question.question_type).to eq('radio')
        expect(question.content).to eq([''])
      end
    end

    # Salvar alterações.
    context 'Salvamento Normal (Botão Salvar)' do
      it 'atualiza atributos e redireciona com sucesso' do
        question.update!(question_type: 'radio', content: ['Old'])

        patch :update, params: {
          template_id: template.id,
          id: question.id,
          template_question: { 
            title: 'Novo Título', 
            question_type: 'radio'
          },
          alternatives: ['Op1', 'Op2'],
          commit: 'Salvar'
        }

        question.reload
        
        expect(question.title).to eq('Novo Título')
        expect(question.content).to eq(['Op1', 'Op2'])
        expect(flash[:notice]).to eq('template alterado com sucesso')
      end

      it 'renderiza erro se a validação falhar' do
        allow_any_instance_of(TemplateQuestion).to receive(:save).and_return(false)
        allow_any_instance_of(TemplateQuestion).to receive_message_chain(:errors, :full_messages).and_return(["Erro de teste"])

        patch :update, params: {
          template_id: template.id,
          id: question.id,
          template_question: { title: '' },
          commit: 'Salvar'
        }

        expect(response).to redirect_to(edit_template_path(template))
        expect(flash[:alert]).to include("Erro de teste")
      end

      it 'limpa conteúdo se salvar como texto (logica redundante do controller)' do
        question.update!(question_type: 'text', content: ['Lixo'])
        
        patch :update, params: {
          template_id: template.id,
          id: question.id,
          template_question: { question_type: 'text' },
          commit: 'Salvar'
        }
        
        question.reload
        expect(question.content).to eq([])
      end
    end
  end

  # Teste de remoção de questão.
  describe 'DELETE #destroy' do

    context 'Quando existe apenas 1 questão' do
      it 'NÃO deleta e redireciona com alerta' do
        expect(template.template_questions.count).to eq(1)

        expect {
          delete :destroy, params: { template_id: template.id, id: question.id }
        }.not_to change(TemplateQuestion, :count)

        expect(response).to redirect_to(edit_template_path(template))
        expect(flash[:alert]).to eq('não é possível salvar template sem questões')
      end
    end

    context 'Quando existem múltiplas questões' do
      before do
        TemplateQuestion.create!(template: template, title: 'Questão 2', question_type: 'text')
      end

      it 'deleta a questão e redireciona com sucesso' do
        expect(template.template_questions.count).to eq(2)

        expect {
          delete :destroy, params: { template_id: template.id, id: question.id }
        }.to change(TemplateQuestion, :count).by(-1)

        expect(response).to redirect_to(edit_template_path(template))
        expect(flash[:notice]).to eq('template alterado com sucesso')
      end
    end
  end

  # Teste legado/específico de adicionar alternativa via POST.
  describe 'POST #add_alternative' do
    let(:radio_question) { TemplateQuestion.create!(template: template, title: 'Q', question_type: 'radio', content: ['A']) }

    it 'adds a new empty alternative' do
      post :add_alternative, params: { template_id: template.id, id: radio_question.id }
      
      radio_question.reload
      expect(radio_question.content).to eq(['A', ''])
      expect(response).to redirect_to(edit_template_path(template))
    end
  end
end