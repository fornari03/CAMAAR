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
  codigo_turma_atual = @fake_classes.last["code"]
  
  # verifica se ja tem essa turma no array de membros
  turma_member_data = @fake_members.find { |m| m["code"] == codigo_turma_atual }

  # senão, cria a estrutura da turma no arquivo de membros
  unless turma_member_data
    turma_member_data = {
      "code" => codigo_turma_atual,
      "dicente" => [],
      "docente" => {
        "nome" => "Professor Mock",
        "usuario" => "99999",
        "email" => "prof@mock.com",
        "ocupacao" => "docente"
      }
    }
    @fake_members << turma_member_data
  end

  # adiciona o aluno na turma
  turma_member_data["dicente"] << {
    "nome" => nome,
    "matricula" => matricula,
    "usuario" => matricula,
    "email" => "#{matricula}@aluno.unb.br",
    "ocupacao" => "dicente"
  }

end

Então('a turma {string} \({string}) deve ser cadastrada no sistema') do |nome, codigo|
  turma = Turma.find_by(codigo: codigo)
  expect(turma).to be_present
  expect(turma.materia.nome).to eq(nome)
end

Então('o usuário {string} \({string}) deve ser cadastrado no sistema') do |nome, matricula|
  usuario = Usuario.find_by(matricula: matricula)
  
  expect(usuario).to be_present
  expect(usuario.nome).to eq(nome)
end

Então('o usuário {string} deve estar matriculado na turma {string}') do |nome_usuario, nome_turma|
  user = Usuario.find_by(nome: nome_usuario)
  
  turma = Turma.joins(:materia).find_by(materias: { nome: nome_turma })
  
  expect(user.turmas).to include(turma)
end

Então('o usuário {string} deve estar matriculado na turma {string} \({string})') do |string, string2, string3|
  user = Usuario.find_by(nome: string)
  
  turma = Turma.joins(:materia).find_by(materias: { nome: string2 }, codigo: string3)
  
  expect(user.turmas).to include(turma)
end

Então('eu devo ver a mensagem de sucesso {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Quando('eu solicito a importação clicando em {string}') do |botao|
  allow(File).to receive(:read).and_wrap_original do |original_method, *args|
    path = args.first.to_s
    
    if path.include?('classes.json')
      puts "👻 MOCK ATIVADO: Retornando classes fake!"
      @fake_classes.to_json
    elsif path.include?('class_members.json')
      puts "👻 MOCK ATIVADO: Retornando membros fake!"
      @fake_members.to_json
    else
      original_method.call(*args)
    end
  end
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