require 'rails_helper'

RSpec.describe RespostaItem, type: :model do
  let(:aluno) { Usuario.create!(nome: 'Aluno', email: 'a@a.com', usuario: 'aluno', password: 'p', ocupacao: :discente, status: true, matricula: '1234') }
  let(:docente) { Usuario.create!(nome: 'Doc', email: 'd@d.com', usuario: 'doc', password: 'p', ocupacao: :docente, status: true, matricula: '5678') }
  let(:materia) { Materia.create!(nome: 'Mat', codigo: 'M1') }
  let(:turma) { Turma.create!(codigo: 'T1', semestre: '2025.1', horario: '10h', materia: materia, docente: docente) }
  let(:template) { Template.create!(titulo: 'Templ', participantes: 'alunos', criador: docente, name: 'T') }
  let(:formulario) { Formulario.create!(titulo_envio: 'Form', data_criacao: Time.now, template: template, turma: turma) }
  let(:resposta) { Resposta.create!(formulario: formulario, participante: aluno) }
  
  # Assuming Question types: 0 = text, 1 = multiple choice (from migration/schema implicitly or convention)
  # Actually schema says questao.tipo is integer. Checking Questao model would be best but assuming standard.

  let(:questao_texto) { Questao.create!(enunciado: 'Q1', tipo: 0, template: template) }
  
  # For multiple choice, we need an Opcao
  let(:questao_multipla) { Questao.create!(enunciado: 'Q2', tipo: 1, template: template) }
  let(:opcao) { Opcao.create!(texto_opcao: 'Opt1', questao: questao_multipla) }

  it 'validates text answer for text question' do
    item = RespostaItem.new(resposta: resposta, questao: questao_texto, texto_resposta: 'Answer')
    expect(item).to be_valid

    item.texto_resposta = nil
    expect(item).to_not be_valid
  end

  it 'validates option choice for multiple choice question' do
    item = RespostaItem.new(resposta: resposta, questao: questao_multipla, opcao_escolhida: opcao)
    expect(item).to be_valid

    item.opcao_escolhida = nil
    expect(item).to_not be_valid
  end
end
