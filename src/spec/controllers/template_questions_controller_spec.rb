require 'rails_helper'

RSpec.describe TemplateQuestionsController, type: :controller do
  let(:admin) { Usuario.create!(nome: 'Admin', email: 'admin@test.com', matricula: '123', usuario: 'admin', password: 'password', ocupacao: :admin, status: true) }
  let(:template) { Template.create!(titulo: 'Test Template', id_criador: admin.id) }
  
  before do
    session[:usuario_id] = admin.id
  end

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

  describe 'PATCH #update' do
    let(:question) { TemplateQuestion.create!(template: template, title: 'Old Title') }

    it 'updates the question attributes' do
      patch :update, params: { template_id: template.id, id: question.id, template_question: { title: 'New Title' } }
      question.reload
      expect(question.title).to eq('New Title')
    end

    it 'serializes alternatives for radio questions' do
      # Assuming the form sends alternatives as a hash or array, but here we simulate what the controller receives
      # The controller logic will likely need to handle params specifically.
      # Let's assume we send a specific param structure that the controller parses.
      # Based on the plan: "colete os inputs das alternativas, serialize em JSON"
      
      # We'll simulate sending raw alternatives if the controller handles it, 
      # or we expect the controller to handle `content` if passed directly.
      # Let's assume the controller accepts `alternatives` param and saves to `content`.
      
      patch :update, params: { 
        template_id: template.id, 
        id: question.id, 
        template_question: { question_type: 'radio' },
        alternatives: ['Option A', 'Option B']
      }
      
      question.reload
      expect(question.question_type).to eq('radio')
      expect(question.content).to eq(['Option A', 'Option B'])
    end
  end

  describe 'POST #add_alternative' do
    let(:question) { TemplateQuestion.create!(template: template, title: 'Questão Teste', question_type: 'radio', content: ['A']) }

    it 'adds a new empty alternative to the content' do
      post :add_alternative, params: { template_id: template.id, id: question.id }
      
      question.reload
      expect(question.content).to eq(['A', ''])
      expect(response).to redirect_to(edit_template_path(template))
    end
  end
end
