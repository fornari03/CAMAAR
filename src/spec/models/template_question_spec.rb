require 'rails_helper'

# Testes de modelo para TemplateQuestion.
#
# Cobre validações de tipo de pergunta e serialização de conteúdo.
RSpec.describe TemplateQuestion, type: :model do
  let(:user) { Usuario.create!(nome: 'User', email: 'user@test.com', matricula: '123', usuario: 'user', password: 'password', ocupacao: :admin, status: true) }
  let(:template) { Template.create!(titulo: 'Test Template', id_criador: user.id) }

  # Testes de validação.
  describe 'validations' do
    it 'is valid with valid attributes' do
      question = TemplateQuestion.new(
        title: 'Valid Question',
        question_type: 'text',
        template: template
      )
      expect(question).to be_valid
    end

    # Validações para perguntas de escolha (radio/checkbox).
    context 'when type is radio or checkbox' do
      it 'adds error if content (alternatives) contains blank values' do
        question = TemplateQuestion.new(
          title: 'Invalid Radio',
          question_type: 'radio',
          content: ['Opção A', ''],
          template: template
        )

        expect(question).not_to be_valid
        expect(question.errors[:base]).to include("Todas as alternativas devem ser preenchidas")
      end

      it 'adds error if content is empty' do
        question = TemplateQuestion.new(
          title: 'Invalid Checkbox',
          question_type: 'checkbox',
          content: [],
          template: template
        )

        expect(question).not_to be_valid
        expect(question.errors[:base]).to include("Todas as alternativas devem ser preenchidas")
      end
    end
  end

  # Testes de serialização JSON.
  describe 'content serialization' do
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