Dado('que o sigaa contém o usuário {string} \({string}) com e-mail {string}') do |nome, matricula, email|
  codigo_padrao = "CIC0097"
  turma_padrao = "TA"

  unless @fake_classes.any? { |c| c["code"] == codigo_padrao }
    @fake_classes << {
      "name" => "Matéria Mock",
      "code" => codigo_padrao,
      "classCode" => turma_padrao,
      "class" => { "semester" => "2024.1", "time" => "35T23" }
    }
  end

  turma_mock = @fake_members.find { |m| m["code"] == codigo_padrao && m["classCode"] == turma_padrao }
  
  unless turma_mock
    turma_mock = {
      "code" => codigo_padrao,
      "classCode" => turma_padrao,
      "semester" => "2024.1",
      "dicente" => [],
      "docente" => { "nome" => "Prof Mock", "usuario" => "999", "email" => "prof@mock.com", "ocupacao" => "docente"}
    }
    @fake_members << turma_mock
  end

  turma_mock["dicente"].reject! { |d| d["matricula"] == matricula }
  
  turma_mock["dicente"] << {
    "nome" => nome,
    "matricula" => matricula,
    "usuario" => matricula,
    "email" => email,
    "ocupacao" => "dicente"
  }
end

Dado('que o sigaa contém o usuário {string} \({string})') do |nome, matricula|
  codigo_padrao = "CIC0097"
  turma_padrao = "TA"

  unless @fake_classes.any? { |c| c["code"] == codigo_padrao }
    @fake_classes << {
      "name" => "Matéria Mock",
      "code" => codigo_padrao,
      "classCode" => turma_padrao,
      "class" => { "semester" => "2024.1", "time" => "35T23" }
    }
  end

  turma_mock = @fake_members.find { |m| m["code"] == codigo_padrao && m["classCode"] == turma_padrao }
  
  unless turma_mock
    turma_mock = {
      "code" => codigo_padrao,
      "classCode" => turma_padrao,
      "semester" => "2024.1",
      "dicente" => [],
      "docente" => { "nome" => "Prof Mock", "usuario" => "999", "email" => "prof@mock.com", "ocupacao" => "docente"}
    }
    @fake_members << turma_mock
  end

  turma_mock["dicente"].reject! { |d| d["matricula"] == matricula }

  turma_mock["dicente"] << {
    "nome" => nome,
    "matricula" => matricula,
    "usuario" => matricula,
    "email" => "#{matricula}@aluno.unb.br",
    "ocupacao" => "dicente"
  }
end

Dado('que o sistema possui o usuário {string} \({string}) cadastrado \(seja pendente ou ativo)') do |nome, matricula|
  Usuario.create!(
    nome: nome,
    matricula: matricula,
    usuario: matricula,
    email: "#{matricula}@sistema.com",
    password: "password123", 
    ocupacao: :discente,
    status: true
  )
end

Dado('o usuário {string} não possui um endereço de e-mail') do |matricula|
  @fake_members.each do |turma|
    if turma["dicente"]
      aluno = turma["dicente"].find { |a| a["matricula"] == matricula }
      aluno["email"] = nil if aluno
    end
  end
end

Então('o usuário {string} \({string}) deve ser criado no sistema com o status {string}') do |nome, matricula, status_esperado|
  user = Usuario.find_by(matricula: matricula)
  
  if status_esperado == "ativo"
    status_esperado = "true"
  else
    status_esperado = "false"
  end

  expect(user).to be_present
  expect(user.nome).to eq(nome)
  expect(user.status.to_s).to eq(status_esperado)
end

Então('nenhum novo e-mail de {string} deve ser enviado para {string}') do |assunto, email_destinatario|
  emails_enviados = ActionMailer::Base.deliveries
  
  email_especifico = emails_enviados.find do |email|
    email.to.include?(email_destinatario) && email.subject.to_s.include?(assunto)
  end

  expect(email_especifico).to be_nil
end

Então('o usuário {string} não deve ser criado no sistema') do |matricula|
  expect(Usuario.find_by(matricula: matricula)).to be_nil
end

Então('eu devo ver uma mensagem de erro {string}') do |mensagem_erro|
  expect(page).to have_content(mensagem_erro)
end

Então('um e-mail de {string} deve ser enviado para {string}') do |assunto, destinatario|
  email = ActionMailer::Base.deliveries.find do |e|
    e.to.include?(destinatario) && e.subject.to_s.include?(assunto)
  end

  expect(email).to be_present
end