require 'json'

Before do
  # mock dos jsons retornados pelo sigaa
  @fake_classes = []
  @fake_members = []

end

Dado('que o sistema não possui nenhuma turma cadastrada') do
  Turma.destroy_all
  Materia.destroy_all
end

Dado('que o sistema não possui nenhum usuário cadastrado') do
  Usuario.where.not(id: @admin.id).destroy_all
end

Dado('que o sigaa contém a turma {string} \({string})') do |nome_turma, codigo_turma|
  @fake_classes << {
    "name" => nome_turma,
    "code" => codigo_turma,
    "class" => {
      "semester" => "2024.1",
      "time" => "35T23"
    }
  }
end

Dado('esta turma contém o participante {string} \({string})') do |nome, matricula|
  @fake_members << {
    "name" => nome,
    "matricula" => matricula,
    "ocupacao" => "aluno",
    "class_code" => @fake_classes.last["codigo"]
  }
end

Então('a turma {string} \({string}) deve ser cadastrada no sistema') do |nome, codigo|
  turma = Turma.find_by(codigo: codigo)
  expect(turma).to be_present
  expect(turma.materia.nome).to eq(nome)
end

Então('o usuário {string} \({string}) deve ser cadastrado no sistema') do |nome, matricula|
  step "o usuário \"#{nome}\" (\"#{matricula}\") deve ser cadastrado no sistema"
end

Então('o usuário {string} deve estar matriculado na turma {string}') do |string, string2|
  user = Usuario.find_by(nome: nome_usuario)
  
  turma = Turma.joins(:materia).find_by(materias: { nome: nome_turma })
  
  expect(user.turmas).to include(turma)
end

Então('o usuário {string} deve estar matriculado na turma {string} \({string})') do |string, string2, string3|
  user = Usuario.find_by(nome: string)
  
  turma = Turma.joins(:materia).find_by(materias: { nome: string2 }, codigo: string3)
  
  expect(user.turmas).to include(turma)
end

Então('eu devo ver a mensagem de sucesso {string}') do |string|
  expect(page).to have_content(mensagem)
end

Quando('eu solicito a importação clicando em {string}') do |botao|
  click_button botao
end

Dado('que o sistema possui o usuário {string} \({string}) cadastrado') do |nome, matricula|
  expect(Usuario.where(matricula: matricula).count).to eq(1)
end

Dado('que o sistema não possui a turma {string} \({string}) cadastrada') do |nome_turma, codigo_turma|
  expect(Turma.joins(:materia).where(materias: { nome: nome_turma }, codigo: codigo_turma).count).to eq(0)
end

Dado('que o sistema possui a turma {string} \({string}) cadastrada') do |nome_turma, codigo_turma|
  expect(Turma.joins(:materia).where(materias: { nome: nome_turma }, codigo: codigo_turma).count).to eq(1)
end

Dado('que o sistema não possui o usuário {string} \({string}) cadastrado') do |nome, matricula|
  expect(Usuario.where(matricula: matricula).count).to eq(0)
end

Dado('que o sigaa está indisponível') do
  pending # TODO: o que poderia ser aqui?
end

Então('eu devo ver a mensagem de erro {string}') do |string|
  expect(page).to have_content(mensagem)
end

Então('nenhuma nova turma deve ser cadastrada no sistema') do
  pending # Write code here that turns the phrase above into concrete actions
end

Então('nenhum novo usuário deve ser cadastrado no sistema') do
  pending # Write code here that turns the phrase above into concrete actions
end

Então('o usuário {string} \({string}) não deve ser duplicado no sistema') do |nome, matricula|
  expect(Usuario.where(matricula: matricula).count).to eq(1)
end