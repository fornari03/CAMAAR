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
  @quantidade_inicial_turmas = Turma.count 
  @quantidade_inicial_usuarios = Usuario.count
  allow(File).to receive(:read).and_wrap_original do |original_method, *args|
    if @simular_erro_arquivo
      raise Errno::ENOENT 
    end

    path = args.first.to_s
    
    if path.include?('classes.json')
      @fake_classes.to_json
    elsif path.include?('class_members.json')
      @fake_members.to_json
    else
      original_method.call(*args)
    end
  end
  click_button botao
end

Dado('que o sistema possui o usuário {string} \({string}) cadastrado') do |nome, matricula|
  Usuario.create!(
    nome: nome,
    matricula: matricula,
    email: "#{matricula}@exemplo.com",
    usuario: matricula,
    password: "password123",
    ocupacao: :discente,
    status: true
  )
end

Dado('que o sistema possui o usuário {string} \({string}) cadastrado com o e-mail {string}') do |nome, matricula, email|
  Usuario.create!(
    nome: nome,
    matricula: matricula,
    email: email,
    usuario: matricula,
    password: "password123",
    ocupacao: :discente,
    status: true
  )
end

Dado('que o sistema não possui a turma {string} \({string}) cadastrada') do |nome_turma, codigo_turma|
  expect(Turma.joins(:materia).where(materias: { nome: nome_turma }, codigo: codigo_turma).count).to eq(0)
end

Dado('que o sistema possui a turma {string} \({string}) cadastrada') do |nome_turma, codigo_turma|
  materia = Materia.find_or_create_by!(codigo: codigo_turma) do |m|
    m.nome = nome_turma
  end

  docente = Usuario.find_by(ocupacao: :docente) || Usuario.create!(
    nome: "Professor Teste",
    matricula: "999999",
    usuario: "999999",
    email: "prof_teste_local@unb.br",
    password: "123",
    ocupacao: :docente,
    status: true
  )

  Turma.find_or_create_by!(codigo: codigo_turma) do |t|
    t.materia = materia
    t.docente = docente
    t.semestre = "2024.1"
    t.horario = "35T23"
  end
end

Dado('que o sistema não possui o usuário {string} \({string}) cadastrado') do |nome, matricula|
  expect(Usuario.where(matricula: matricula).count).to eq(0)
end

Dado('que o sigaa está indisponível') do
  @simular_erro_arquivo = true
end

Então('nenhuma nova turma deve ser cadastrada no sistema') do
  expect(Turma.count).to eq(@quantidade_inicial_turmas)
end

Então('nenhum novo usuário deve ser cadastrado no sistema') do
  expect(Usuario.count).to eq(@quantidade_inicial_usuarios)
end

Então('o usuário {string} \({string}) não deve ser duplicado no sistema') do |nome, matricula|
  expect(Usuario.where(matricula: matricula).count).to eq(1)
end

Então('os outro botões na página devem ser liberados') do
  botoes_para_verificar = ["Editar Templates", "Enviar Formularios", "Resultados"]

  botoes_para_verificar.each do |texto_botao|
    botao = find_button(texto_botao)
    
    expect(botao).not_to be_disabled
    expect(botao[:class]).to include("bg-green-500")
  end
end

Dado('a fonte de dados externa indica que o e-mail de {string} agora é {string}') do |matricula, novo_email|
  found = false
  @fake_members.each do |turma|
    aluno = turma["dicente"].find { |d| d["matricula"] == matricula }
    if aluno
      aluno["email"] = novo_email
      found = true
    end
  end
  
  unless found
    raise "Erro no Teste: Tentou atualizar email do aluno #{matricula}, mas ele não existe no Mock inicial."
  end
end

Dado('a fonte de dados externa indica que {string} está matriculado em {string}') do |matricula_aluno, codigo_turma|
  turma_mock = @fake_members.find { |m| m["code"] == codigo_turma }
  
  unless turma_mock
    turma_mock = { 
      "code" => codigo_turma, 
      "dicente" => [], 
      "docente" => { "nome" => "Prof Mock", "usuario" => "999" } 
    }
    @fake_members << turma_mock
  end

  novo_aluno_mock = {
    "nome" => "Fulano de Tal",
    "matricula" => matricula_aluno,
    "usuario" => matricula_aluno,
    "email" => "#{matricula_aluno}@email.com",
    "ocupacao" => "dicente"
  }

  turma_mock["dicente"] << novo_aluno_mock
end

Dado('a fonte de dados externa indica que o nome de {string} agora é {string}') do |matricula, novo_nome|
  @fake_members.each do |turma|
    aluno = turma["dicente"].find { |d| d["matricula"] == matricula }
    if aluno
      aluno["nome"] = novo_nome
    end
  end
end

Dado('a fonte de dados externa indica que o nome da turma {string} agora é {string}') do |codigo_turma, novo_nome|
  turma = @fake_classes.find { |c| c["code"] == codigo_turma }
  turma["name"] = novo_nome if turma
end

Dado('a fonte de dados externa indica que {string} não está mais presente') do |identificador|
  @fake_classes.reject! { |c| c["code"] == identificador }
  
  @fake_members.reject! { |m| m["code"] == identificador }

  @fake_members.each do |turma|
    turma["dicente"].reject! { |d| d["matricula"] == identificador }
  end
end

Dado('o usuário {string} ainda não está matriculado na turma {string}') do |nome_usuario, nome_turma|
  user = Usuario.find_by(nome: nome_usuario)
  turma = Turma.find_by(nome: nome_turma)
  
  expect(user.turmas).not_to include(turma)
end

Então('o e-mail do usuário {string} deve ser atualizado para {string}') do |matricula, novo_email|
  usuario = Usuario.find_by(matricula: matricula)
  expect(usuario.email).to eq(novo_email)
end

Então('o usuário {string} deve ser matriculado na turma {string}') do |nome_usuario, nome_turma|
  user = Usuario.find_by(nome: nome_usuario)
  turma = Turma.find_by(nome: nome_turma)
  
  expect(user.turmas).to include(turma)
end

Então('o nome do usuário {string} deve ser atualizado para {string}') do |matricula, novo_nome|
  usuario = Usuario.find_by(matricula: matricula)
  expect(usuario.nome).to eq(novo_nome)
end

Então('o nome da turma {string} deve ser atualizado para {string}') do |codigo_turma, novo_nome|
  turma = Turma.find_by(codigo: codigo_turma)
  expect(turma.nome).to eq(novo_nome)
end

Então('o usuário {string} deve ser excluído do sistema') do |matricula|
  usuario = Usuario.find_by(matricula: matricula)
  expect(usuario).to be_nil
end