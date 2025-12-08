require 'rails_helper'

RSpec.describe Usuario, type: :model do
  describe 'associations' do
    it 'has many respostas' do
      expect(Usuario.reflect_on_association(:respostas).macro).to eq :has_many
    end
  end

  describe '#pendencias' do
    let(:aluno) { Usuario.create!(nome: 'Aluno', email: 'a@test.com', matricula: '123', usuario: 'aluno', password: 'password', ocupacao: 'discente', status: true) }
    let(:template) { Template.create!(name: 'T1', id_criador: aluno.id, titulo: 'T', participantes: 'todos') }
    let(:turma) { Turma.create!(codigo: 'X', semestre: '2024', horario: '2M', materia: Materia.create!(codigo: 'M', nome: 'N'), docente: aluno) }
    let(:formulario) { Formulario.create!(template: template, turma: turma, titulo_envio: 'Envio 1', data_criacao: Time.now) }
    
    it 'returns only unanswered responses' do
      formulario2 = Formulario.create!(template: template, turma: turma, titulo_envio: 'Envio 2', data_criacao: Time.now)
      r1 = Resposta.create!(participante: aluno, formulario: formulario, respondido: false)
      r2 = Resposta.create!(participante: aluno, formulario: formulario2, respondido: true, data_submissao: Time.now)

      expect(aluno.pendencias).to include(r1)
      expect(aluno.pendencias).not_to include(r2)
    end
  end
end
