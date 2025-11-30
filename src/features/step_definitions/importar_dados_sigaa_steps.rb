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
    "codigo" => codigo_turma,
    "semestre" => "2024.1",
    "horario" => "35T23" 
  }
end

Dado('esta turma contém o participante {string} \({int})') do |string, int|
  @fake_members << {
    "name" => string,
    "matricula" => int,
    "ocupacao" => "aluno",
    "class_code" => @fake_classes.last["codigo"]
  }
end

Então('a turma {string} \({string}) deve ser cadastrada no sistema') do |nome, codigo|
  turma = Turma.find_by(codigo: codigo)
  expect(turma).to be_present
  expect(turma.materia.nome).to eq(nome)
end

Então('o usuário {string} \({int}) deve ser cadastrado no sistema') do |string, int|
  step "o usuário \"#{nome}\" (\"#{matricula}\") deve ser cadastrado no sistema"
end

Então('o usuário {string} deve estar matriculado na turma {string}') do |string, string2|
  user = Usuario.find_by(nome: nome_usuario)
  
  # ATENÇÃO: Seu model Usuario não tem associação direta com turmas como aluno!
  # O código abaixo assume que você criará 'has_and_belongs_to_many :turmas' 
  # ou 'has_many :matriculas' no model Usuario.
  
  # Buscando a turma pelo nome da matéria associada
  turma = Turma.joins(:materia).find_by(materias: { nome: nome_turma })
  
  expect(user.turmas).to include(turma)
end

Então('eu devo ver a mensagem de sucesso {string}') do |string|
  expect(page).to have_content(mensagem)
end




Dado('que o sistema possui o usuário {string} \({int}) cadastrado') do |string, int|
# Dado('que o sistema possui o usuário {string} \({float}) cadastrado') do |string, float|
  pending # Write code here that turns the phrase above into concrete actions
end

Dado('que o sistema não possui a turma {string} \(CIC0002) cadastrada') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Dado('que o sigaa contém a turma {string} \(CIC0002)') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Então('a turma {string} \(CIC0002) deve ser cadastrada no sistema') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Então('o usuário {string} deve estar matriculado na turma {string} \(CIC0002)') do |string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Dado('que o sistema possui a turma {string} \(CIC0001) cadastrada') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Dado('que o sistema não possui o usuário {string} \({int}) cadastrado') do |string, int|
# Dado('que o sistema não possui o usuário {string} \({float}) cadastrado') do |string, float|
  pending # Write code here that turns the phrase above into concrete actions
end

Então('o usuário {string} deve estar matriculado na turma {string} \(CIC0001)') do |string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Dado('que o sigaa está indisponível') do
  pending # Write code here that turns the phrase above into concrete actions
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

Dado('que o sigaa contém a turma {string} \(CIC0003)') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Então('o usuário {string} \({int}) não deve ser duplicado no sistema') do |string, int|
  expect(Usuario.where(matricula: matricula).count).to eq(1)
end

Então('o usuário {string} deve estar matriculado na turma {string} \(CIC0003)') do |string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end