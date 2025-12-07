require 'rails_helper'

RSpec.describe TemplateQuestion, type: :model do
  describe 'content serialization' do
    let(:user) { Usuario.create!(nome: 'User', email: 'user@test.com', matricula: '123', usuario: 'user', password: 'password', ocupacao: :admin, status: true) }
    let(:template) { Template.create!(titulo: 'Test Template', id_criador: user.id) }
    
    it 'can save and retrieve an array of strings as JSON' do
      question = TemplateQuestion.create!(
        title: 'Question 1',
        question_type: 'radio',
        content: ['Option A', 'Option B'],
        template: template
      )

      question.reload
      expect(question.content).to be_an(Array)
      expect(question.content).to eq(['Option A', 'Option B'])
    end

    it 'defaults to an empty array' do
      question = TemplateQuestion.create!(
        title: 'Question 2',
        template: template
      )
      
      expect(question.content).to eq([])
    end
  end
end
