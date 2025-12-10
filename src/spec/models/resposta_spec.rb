require 'rails_helper'

RSpec.describe Resposta, type: :model do
  let(:aluno) { Usuario.create!(nome: 'Aluno', email: 'a@a.com', usuario: 'aluno', password: 'p', ocupacao: :discente, status: true, matricula: '1234') }
  let(:docente) { Usuario.create!(nome: 'Doc', email: 'd@d.com', usuario: 'doc', password: 'p', ocupacao: :docente, status: true, matricula: '5678') }
  let(:materia) { Materia.create!(nome: 'Mat', codigo: 'M1') }
  let(:turma) { Turma.create!(codigo: 'T1', semestre: '2025.1', horario: '10h', materia: materia, docente: docente) }
  let(:template) { Template.create!(titulo: 'Templ', participantes: 'alunos', criador: docente, name: 'T') }
  let(:formulario) { Formulario.create!(titulo_envio: 'Form', data_criacao: Time.now, template: template, turma: turma) }

  subject { described_class.new(formulario: formulario, participante: aluno) }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'belongs to a formulario' do
    subject.formulario = nil
    expect(subject).to_not be_valid
  end

  it 'belongs to a participante' do
    subject.participante = nil
    expect(subject).to_not be_valid
  end

  it 'validates uniqueness of participante per formulario' do
    subject.save!
    duplicate = described_class.new(formulario: formulario, participante: aluno)
    expect(duplicate).to_not be_valid
  end

  describe '#respondido?' do
    it 'returns true if data_submissao is present' do
      subject.data_submissao = Time.now
      expect(subject.respondido?).to be true
    end

    it 'returns false if data_submissao is nil' do
      subject.data_submissao = nil
      expect(subject.respondido?).to be false
    end
  end
end
