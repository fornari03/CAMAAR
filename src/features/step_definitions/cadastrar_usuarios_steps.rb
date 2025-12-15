# =========================================
# Contexto (Dado)
# =========================================

Dado('que o sigaa contém o usuário {string} \({string}) com e-mail {string}') do |nome, matricula, email|
  turma_mock = setup_sigaa_context
  upsert_sigaa_student(turma_mock, nome, matricula, email)
end

Dado('que o sigaa contém o usuário {string} \({string})') do |nome, matricula|
  turma_mock = setup_sigaa_context
  email_temp = "#{matricula}@temp.com"
  upsert_sigaa_student(turma_mock, nome, matricula, email_temp)
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

# =========================================
# Verificações (Então)
# =========================================

Então('o usuário {string} \({string}) deve ser criado no sistema com o status {string}') do |nome, matricula, status_texto|
  status_booleano = (status_texto == "ativo")
  verify_user_creation_data(matricula, nome, status_booleano)
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