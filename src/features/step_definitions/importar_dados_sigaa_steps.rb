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

Dado('que o sigaa contém a turma {string} da matéria {string} \({string})') do |codigo_turma, nome_materia, codigo_materia|
  @fake_classes << {
    "name" => nome_materia,
    "code" => codigo_materia,
    "classCode" => codigo_turma,
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
      "classCode" => @fake_classes.last["classCode"],
      "semester" => "2024.1",
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

Então('a turma {string} da matéria {string} \({string}) deve ser cadastrada no sistema') do |codigo_turma, nome_materia, codigo_materia|
  materia = Materia.find_by(codigo: codigo_materia)
  turma = Turma.joins(:materia).find_by(codigo: codigo_turma, materia: materia)
  expect(turma).to be_present
  expect(turma.materia.nome).to eq(nome_materia)
end

Então('o usuário {string} \({string}) deve ser cadastrado no sistema') do |nome, matricula|
  usuario = Usuario.find_by(matricula: matricula)
  
  expect(usuario).to be_present
  expect(usuario.nome).to eq(nome)
end

Então('o usuário {string} deve estar matriculado na turma {string} da matéria {string}') do |matricula, codigo_turma, codigo_materia|
  user = Usuario.find_by(matricula: matricula)
  materia = Materia.find_by(codigo: codigo_materia)
  turma = Turma.find_by(codigo: codigo_turma, materia: materia)

  expect(turma).to be_present
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

Dado('que o sistema possui a turma {string} da matéria {string} \({string}) cadastrada') do |codigo_turma, nome_materia, codigo_materia|
  materia = Materia.find_or_create_by!(codigo: codigo_materia) do |m|
    m.nome = nome_materia
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

Então('nenhum usuário duplicado deve ser criado') do
  expect(Usuario.where(matricula: "150084006").count).to eq(1)
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
  matricula_str = matricula.to_s
  
  codigo_materia_padrao = "CIC0097" 
  codigo_turma_padrao = "TA"

  turma_mock = @fake_members.find { |m| m["dicente"].any? { |d| d["matricula"].to_s == matricula_str } }
  
  unless turma_mock
    turma_mock = @fake_members.find { |m| m["code"] == codigo_materia_padrao } || {
      "code" => codigo_materia_padrao,
      "classCode" => codigo_turma_padrao,
      "semester" => "2024.1",
      "dicente" => [],
      "docente" => { "nome" => "Prof Mock", "usuario" => "999", "email" => "mock@email"}
    }
    @fake_members << turma_mock unless @fake_members.include?(turma_mock)
  end

  unless @fake_classes.any? { |c| c["code"] == turma_mock["code"] }
    @fake_classes << {
      "name" => "Matéria Mock",
      "code" => turma_mock["code"],
      "class" => { "semester" => "2024.1", "time" => "35T23", "classCode" => "TA"}
    }
  end

  @fake_members.each do |t|
    t["dicente"].reject! { |d| d["matricula"].to_s == matricula_str }
  end

  turma_mock["dicente"] << {
    "nome" => "Nome Genérico",
    "matricula" => matricula_str,
    "usuario" => matricula_str,
    "email" => novo_email,
    "ocupacao" => "dicente"
  }
end

Dado('que o sistema possui a turma {string} da matéria {string} cadastrada') do |codigo_turma, codigo_materia|
  docente = Usuario.find_by(ocupacao: :docente) || Usuario.create!(
    nome: "Docente Padrão", matricula: "99999", usuario: "prof", 
    email: "prof@unb.br", password: "123", ocupacao: :docente, status: true
  )

  materia = Materia.find_or_create_by!(codigo: codigo_materia) do |m|
    m.nome = "Matéria #{codigo_materia}"
  end

  Turma.find_or_create_by!(codigo: codigo_turma, materia: materia) do |t|
    t.docente = docente
    t.semestre = "2024.1"
    t.horario = "35T23"
  end
end

Dado('o usuário {string} ainda não está matriculado na turma {string} da matéria {string}') do |matricula_usuario, codigo_turma, codigo_materia|
  user = Usuario.find_by(matricula: matricula_usuario)
  turma = Turma.joins(:materia).find_by(codigo: codigo_turma, materias: { codigo: codigo_materia })

  if turma
    expect(user.turmas).not_to include(turma)
  end
end

Dado('a fonte de dados externa indica que {string} está matriculado na turma {string} da matéria {string}') do |matricula, codigo_turma, codigo_materia|
  matricula_str = matricula.to_s

  unless @fake_classes.any? { |c| c["code"] == codigo_materia }
    @fake_classes << {
      "name" => "Matéria Importada",
      "code" => codigo_materia,
      "class" => { "semester" => "2024.1", "time" => "35T23", "classCode" => codigo_turma }
    }
  end

  turma_mock = @fake_members.find { |m| m["code"] == codigo_materia && m["classCode"] == codigo_turma }

  unless turma_mock
    turma_mock = {
      "code" => codigo_materia,
      "classCode" => codigo_turma,
      "semester" => "2024.1",
      "dicente" => [],
      "docente" => { "nome" => "Prof Mock", "usuario" => "999", "email" => "mock@email"}
    }

    turma_mock["dicente"] << {
    "nome" => "Aluno Importado",
    "matricula" => matricula_str,
    "usuario" => matricula_str,
    "email" => "#{matricula_str}@aluno.unb.br",
    "ocupacao" => "dicente"
    }

    @fake_members << turma_mock
  end
end

Dado('a fonte de dados externa indica que o nome de {string} agora é {string}') do |matricula, novo_nome|
  matricula_str = matricula.to_s
  codigo_materia_padrao = "CIC0097"
  codigo_turma_padrao = "TA"

  unless @fake_classes.any? { |c| c["code"] == codigo_materia_padrao }
    @fake_classes << {
      "name" => "Matéria Mock",
      "code" => codigo_materia_padrao,
      "class" => { "semester" => "2024.1", "time" => "35T23", classCode: "TA"}
    }
  end

  turma_mock = @fake_members.find { |m| m["code"] == codigo_materia_padrao && m["classCode"] == codigo_turma_padrao }
  unless turma_mock
    turma_mock = {
      "code" => codigo_materia_padrao,
      "classCode" => codigo_turma_padrao,
      "semester" => "2024.1",
      "dicente" => [],
      "docente" => { "nome" => "Prof Mock", "usuario" => "999", "email" => "mock@email"}
    }
    @fake_members << turma_mock
  end

  turma_mock["dicente"].reject! { |d| d["matricula"].to_s == matricula_str }

  turma_mock["dicente"] << {
    "nome" => novo_nome,
    "matricula" => matricula_str,
    "usuario" => matricula_str,
    "email" => "#{matricula_str}@aluno.unb.br",
    "ocupacao" => "dicente"
  }
end

Dado('que o sistema possui a matéria {string} cadastrada') do |codigo_materia|
  Materia.find_or_create_by!(codigo: codigo_materia) do |m|
    m.nome = "Matéria #{codigo_materia}"
  end
end

Dado('a fonte de dados externa indica que o nome da matéria {string} agora é {string}') do |codigo_materia, novo_nome|
  class_mock = @fake_classes.find { |c| c["code"] == codigo_materia }

  unless class_mock
    class_mock = {
      "code" => codigo_materia,
      "name" => "Nome Antigo",
      "class" => { "semester" => "2024.1", "time" => "35T23" }
    }
    @fake_classes << class_mock
  end

  class_mock["name"] = novo_nome
end

Dado('a fonte de dados externa indica que {string} não está mais presente') do |identificador|
  @fake_classes.reject! { |c| c["code"] == identificador }
  @fake_members.reject! { |m| m["code"] == identificador }
  
  @fake_members.each do |turma|
    turma["dicente"].reject! { |d| d["matricula"].to_s == identificador.to_s }
  end
end

Então('o e-mail do usuário {string} deve ser atualizado para {string}') do |matricula, novo_email|
  usuario = Usuario.find_by(matricula: matricula)
  expect(usuario).to be_present
  expect(usuario.email).to eq(novo_email)
end

Então('o usuário {string} deve ser matriculado na turma {string} da matéria {string}') do |matricula, codigo_turma, codigo_materia|
  user = Usuario.find_by(matricula: matricula)
  turma = Turma.joins(:materia).find_by(codigo: codigo_turma, materias: { codigo: codigo_materia })
  
  expect(user).to be_present
  expect(turma).to be_present
  expect(user.turmas).to include(turma)
end

Então('o nome do usuário {string} deve ser atualizado para {string}') do |matricula, novo_nome|
  usuario = Usuario.find_by(matricula: matricula)
  expect(usuario).to be_present
  expect(usuario.nome).to eq(novo_nome)
end

Então('o nome da matéria {string} deve ser atualizado para {string}') do |codigo_materia, novo_nome|
  materia = Materia.find_by(codigo: codigo_materia)
  expect(materia).to be_present
  expect(materia.nome).to eq(novo_nome)
end

Então('o usuário {string} deve ser excluído do sistema') do |matricula|
  expect(Usuario.find_by(matricula: matricula)).to be_nil
end
