# =========================================
# Contexto (Dado)
# =========================================

# Cria configuração de usuário no mock do SIGAA.
#
# Argumentos:
#   - nome (String): Nome do usuário.
#   - matricula (String): Matrícula.
#   - email (String): Email.
#
# Efeitos Colaterais:
#   - Modifica estado do mock do SIGAA.
Dado('que o sigaa contém o usuário {string} \({string}) com e-mail {string}') do |nome, matricula, email|
  turma_mock = setup_sigaa_context
  upsert_sigaa_student(turma_mock, nome, matricula, email)
end

# Cria configuração de usuário no mock do SIGAA com email temporário.
#
# Argumentos:
#   - nome (String): Nome.
#   - matricula (String): Matrícula.
#
# Efeitos Colaterais:
#   - Modifica estado do mock do SIGAA.
Dado('que o sigaa contém o usuário {string} \({string})') do |nome, matricula|
  turma_mock = setup_sigaa_context
  email_temp = "#{matricula}@temp.com"
  upsert_sigaa_student(turma_mock, nome, matricula, email_temp)
end

# Cria usuário diretamente no sistema (ativo).
#
# Argumentos:
#   - nome (String): Nome.
#   - matricula (String): Matrícula.
#
# Efeitos Colaterais:
#   - Cria registro de Usuario.
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

# Remove email de usuário no mock do SIGAA.
#
# Argumentos:
#   - matricula (String): Matrícula.
#
# Efeitos Colaterais:
#   - Modifica estado do mock.
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

# Verifica criação de usuário e status.
#
# Argumentos:
#   - nome (String): Nome esperado.
#   - matricula (String): Matrícula.
#   - status_texto (String): "ativo" ou outro.
#
# Retorno:
#   - (Boolean): Resultado da asserção.
Então('o usuário {string} \({string}) deve ser criado no sistema com o status {string}') do |nome, matricula, status_texto|
  status_booleano = (status_texto == "ativo")
  verify_user_creation_data(matricula, nome, status_booleano)
end

# Verifica que email específico NÃO foi enviado.
#
# Argumentos:
#   - assunto (String): Trecho do assunto.
#   - email_destinatario (String): Email destinatário.
#
# Retorno:
#   - (Boolean): Asserção de não existência.
Então('nenhum novo e-mail de {string} deve ser enviado para {string}') do |assunto, email_destinatario|
  emails_enviados = ActionMailer::Base.deliveries
  
  email_especifico = emails_enviados.find do |email|
    email.to.include?(email_destinatario) && email.subject.to_s.include?(assunto)
  end

  expect(email_especifico).to be_nil
end

# Verifica que usuário não existe no banco.
#
# Argumentos:
#   - matricula (String): Matrícula.
#
# Retorno:
#   - (Boolean): Asserção de nil.
Então('o usuário {string} não deve ser criado no sistema') do |matricula|
  expect(Usuario.find_by(matricula: matricula)).to be_nil
end

# Verifica mensagem de erro na página.
#
# Argumentos:
#   - mensagem_erro (String): Texto da mensagem.
Então('eu devo ver uma mensagem de erro {string}') do |mensagem_erro|
  expect(page).to have_content(mensagem_erro)
end

# Verifica envio de email.
#
# Argumentos:
#   - assunto (String): Assunto.
#   - destinatario (String): Email.
#
# Retorno:
#   - (Boolean): Asserção de presença.
Então('um e-mail de {string} deve ser enviado para {string}') do |assunto, destinatario|
  email = ActionMailer::Base.deliveries.find do |e|
    e.to.include?(destinatario) && e.subject.to_s.include?(assunto)
  end

  expect(email).to be_present
end