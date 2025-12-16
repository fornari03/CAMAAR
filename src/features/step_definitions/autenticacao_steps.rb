# =========================================
# Contexto (Dado)
# =========================================

# Navega para a página de login.
#
# Argumentos:
#   - Nenhum
#
# Efeitos Colaterais:
#   - Altera a página atual para /login.
Dado('que eu estou na página de login') do
  visit "/login"
end

# Navega para a página de login (redundante).
#
# Argumentos:
#   - Nenhum
#
# Efeitos Colaterais:
#   - Altera a página atual para /login.
Dado('eu estou na página de login') do
  visit "/login"
end

# Cria um usuário com os dados especificados.
#
# Argumentos:
#   - nome (String): Nome do usuário.
#   - email (String): Email do usuário.
#   - matricula (String): Matrícula do usuário.
#   - senha (String): Senha do usuário.
#
# Efeitos Colaterais:
#   - Cria um registro na tabela usuarios.
Dado('existe um usuário {string} cadastrado com email {string}, matrícula {string} e senha {string}') do |nome, email, matricula, senha|
  Usuario.create!(
    nome: nome,
    email: email,
    usuario: email,
    matricula: matricula,
    password: senha,
    password_confirmation: senha,
    ocupacao: 'discente',
    status: true
  )
end

# Cria um usuário administrador com os dados especificados.
#
# Argumentos:
#   - nome (String): Nome do usuário.
#   - email (String): Email do usuário.
#   - matricula (String): Matrícula do usuário.
#   - senha (String): Senha do usuário.
#
# Efeitos Colaterais:
#   - Cria um registro na tabela usuarios com ocupacao 'admin'.
Dado('existe um usuário {string} cadastrado com email {string}, matrícula {string}, senha {string} e com permissão de administrador') do |nome, email, matricula, senha|
  Usuario.create!(
    nome: nome,
    email: email,
    usuario: email,
    matricula: matricula,
    password: senha,
    password_confirmation: senha,
    ocupacao: 'admin',
    status: true
  )
end

# Cria um usuário pré-cadastrado via SIGAA com status pendente.
#
# Argumentos:
#   - nome (String): Nome do usuário.
#   - matricula (String): Matrícula do usuário.
#   - status_desc (String): Descrição do status (não utilizado diretamente na lógica, fixado como false).
#
# Efeitos Colaterais:
#   - Cria um registro na tabela usuarios com status false.
Dado('que existe um usuário {string} \({string}) pré-cadastrado via SIGAA, mas com status {string}') do |nome, matricula, status_desc|
  Usuario.create!(
    nome: nome,
    matricula: matricula,
    usuario: matricula,
    email: "#{matricula}@aluno.unb.br",
    password: "SenhaTemporaria123!",
    ocupacao: :discente,
    status: false
  )
end

# Define o papel do usuário (não implementado).
#
# Argumentos:
#   - role (String): Papel do usuário.
Dado('que eu sou um {string} não autenticado') do |role|
  pending "Authentication logic for unauthenticated #{role} not implemented"
end

# =========================================
# Ações (Quando)
# =========================================

# Preenche um campo do formulário.
#
# Argumentos:
#   - campo (String): Nome do campo (Label).
#   - valor (String): Valor a ser preenchido.
#
# Efeitos Colaterais:
#   - Altera o valor de um input na página.
Quando('eu preencho o campo {string} com {string}') do |campo, valor|
  if campo == 'Email'
    fill_in 'Usuário', with: valor
  else
    fill_in campo, with: valor
  end
end

# Step pendente para preenchimento genérico.
#
# Argumentos:
#   - string (String): Primeiro argumento.
#   - string2 (String): Segundo argumento.
Quando('eu preencho {string} com {string}') do |string, string2|
  pending
end

# Tenta acessar funcionalidade de criação (pendente).
#
# Argumentos:
#   - button_text (String): Texto do botão.
Quando('eu tento acessar a funcionalidade de criação \(clicar no botão {string})') do |button_text|
  pending "Access control testing logic not implemented"
end

# =========================================
# Verificações (Então)
# =========================================

# Verifica redirecionamento para página inicial.
#
# Argumentos:
#   - Nenhum
#
# Retorno:
#   - (Boolean): Resultado da asserção de caminho.
Então('eu devo ser redirecionado para a página inicial') do
  expect(page).to have_current_path("/")
end

# Verifica redirecionamento para página de administrador.
#
# Argumentos:
#   - Nenhum
#
# Retorno:
#   - (Boolean): Resultado da asserção de caminho.
Então('eu devo ser redirecionado para a página de administrador') do 
  expect(page.current_path).to eq(admin_gerenciamento_path)
end

# Verifica presença de mensagem na tela.
#
# Argumentos:
#   - mensagem (String): Mensagem esperada.
#
# Retorno:
#   - (Boolean): Resultado da asserção de conteúdo.
Então('eu devo ver a mensagem de Login {string}') do |mensagem|
  texto = mensagem.sub(/\.$/, '')
  expect(page).to have_content(texto)
end

# Verifica ausência de opção no menu lateral.
#
# Argumentos:
#   - opcao (String): Texto da opção.
#
# Retorno:
#   - (Boolean): Resultado da asserção de ausência de conteúdo.
Então('eu NÃO devo ver a opção {string} no menu lateral') do |opcao|
  within('aside') do
    expect(page).not_to have_content(opcao)
  end
end

# Verifica presença de opção no menu lateral.
#
# Argumentos:
#   - texto (String): Texto da opção.
#
# Retorno:
#   - (Boolean): Resultado da asserção de conteúdo.
Então('eu devo ver a opção {string} no menu lateral') do |texto|
  expect(page).to have_content(texto)
end

# Verifica permanência na página de login.
#
# Argumentos:
#   - Nenhum
#
# Retorno:
#   - (Boolean): Resultado da asserção de caminho.
Então('eu devo permanecer na página de login') do
  expect(page).to have_current_path("/login")
end

# Verifica o status de um usuário no banco de dados.
#
# Argumentos:
#   - email_ou_matricula (String): Identificador do usuário.
#   - status (Boolean): Status esperado (true/false).
#
# Efeitos Colaterais:
#   - Realiza consulta ao banco de dados.
#
# Retorno:
#   - (Boolean): Resultado da asserção de igualdade.
Então('o status do usuário {string} deve continuar {string}') do |email_ou_matricula, status|
  usuario = Usuario.find_by(email: email_ou_matricula) || Usuario.find_by(matricula: email_ou_matricula)
  expect(usuario.status).to eq(status)
end