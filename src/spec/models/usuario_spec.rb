require 'rails_helper'

RSpec.describe Usuario, type: :model do
  describe 'associations' do
    it 'has many respostas' do
      expect(Usuario.reflect_on_association(:respostas).macro).to eq :has_many
    end
  end

  describe 'attributes' do
    it "persists attributes correctly" do
      u = Usuario.create!(
        nome: 'usuario',
        email: 'usuario@email.com',
        matricula: '1234',
        usuario: 'usuario',
        password: 'senha123',
        ocupacao: 'discente',
        status: true
      )

      expect(u).to have_attributes(
        nome: 'usuario',
        email: 'usuario@email.com',
        matricula: '1234',
        usuario: 'usuario',
        ocupacao: 'discente',
        status: true
      )

      expect(u.authenticate('senha123')).to be_truthy if u.respond_to?(:authenticate)
    end
  end

  describe '#pendencias' do
    let(:aluno) { Usuario.create!(nome: 'Aluno', email: 'a@test.com', matricula: '123', usuario: 'aluno', password: 'password', ocupacao: :discente, status: true) }
    let(:template) { Template.create!(name: 'T1', id_criador: aluno.id, titulo: 'T', participantes: 'todos') }
    let(:turma) { Turma.create!(codigo: 'X', semestre: '2024', horario: '2M', materia: Materia.create!(codigo: 'M', nome: 'N'), docente: aluno) }
    let(:formulario) { Formulario.create!(template: template, turma: turma, titulo_envio: 'Envio 1', data_criacao: Time.now) }
    
    it 'returns only unanswered responses' do
      formulario2 = Formulario.create!(template: template, turma: turma, titulo_envio: 'Envio 2', data_criacao: Time.now)
      r1 = Resposta.create!(participante: aluno, formulario: formulario)
      r2 = Resposta.create!(participante: aluno, formulario: formulario2, data_submissao: Time.now)

      expect(aluno.pendencias).to include(r1)
      expect(aluno.pendencias).not_to include(r2)
    end
  end
end
