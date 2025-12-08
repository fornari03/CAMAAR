require 'rails_helper'

RSpec.describe Turma, type: :model do
  describe 'associations' do
    it 'has many formularios' do
      expect(Turma.reflect_on_association(:formularios).macro).to eq :has_many
    end
    it 'has many matriculas' do
      expect(Turma.reflect_on_association(:matriculas).macro).to eq :has_many
    end
    it 'has many alunos through matriculas' do
      assoc = Turma.reflect_on_association(:alunos)
      expect(assoc.macro).to eq :has_many
      expect(assoc.options[:through]).to eq :matriculas
    end
  end

  describe '#distribuir_formulario' do
    let(:docente) { Usuario.create!(nome: 'Prof', email: 'prof@test.com', matricula: '111', usuario: 'prof', password: 'password', ocupacao: 'docente', status: true) }
    let(:turma) { Turma.create!(codigo: 'T1', semestre: '2024.1', horario: '35T', materia: Materia.create!(codigo: 'M1', nome: 'Mat'), docente: docente) }
    let(:template) { Template.create!(name: 'Template 1', id_criador: docente.id, titulo: 'Titulo', participantes: 'todos') }
    let(:aluno1) { Usuario.create!(nome: 'A1', email: 'a1@test.com', matricula: '222', usuario: 'a1', password: 'password', ocupacao: 'discente', status: true) }

    before do
      Matricula.create!(usuario: aluno1, turma: turma) 
    end

    it 'creates a formulario and respostas for all members' do
      expect {
        turma.distribuir_formulario(template)
      }.to change(Formulario, :count).by(1)
      .and change(Resposta, :count).by(2) # 1 aluno + 1 docente

      created_form = Formulario.last
      expect(created_form.turma).to eq(turma)
      expect(created_form.template).to eq(template)

      respostas = created_form.respostas
      expect(respostas.map(&:id_participante)).to include(aluno1.id, docente.id)
      expect(respostas.first.respondido?).to be_falsey
      expect(respostas.first.data_submissao).to be_nil
    end
  end
end
