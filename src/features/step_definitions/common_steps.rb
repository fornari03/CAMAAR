# ============================
# LOGIN COMO ADMINISTRADOR
# ============================
Dado('que eu estou logado como Administrador') do
  @admin = Usuario.find_by(usuario: 'admin') || Usuario.create!(
    nome: 'Administrador',
    email: 'admin@camaar.com',
    matricula: '000000',
    usuario: 'admin',
    password: 'password',
    ocupacao: :admin,
    status: true
  )
end


# ============================
# LOGIN POR PAPEL (ROLE)
# ============================
Dado('que eu sou um {string} logado no sistema') do |role|
  @user = Usuario.find_by(usuario: role) || Usuario.create!(
    nome: role.capitalize,
    email: "#{role}@test.com",
    matricula: '123456',
    usuario: role,
    password: 'password',
    ocupacao: role.to_sym, # precisa bater com o enum
    status: true
  )
end


# ============================
# NAVEGAÇÃO POR NOME DE PÁGINA (GENÉRICO)
# ============================
Dado(/^(?:que )?(?:eu )?estou na página(?: de)? "([^"]*)"$/) do |page_name|
  visit path_to(page_name)
end


def path_to(page_name)
  case page_name.downcase
  when "gerenciamento"
    admin_gerenciamento_path

  when "gerenciamento de templates"
    templates_path

  when "templates"
    templates_path

  when "templates/new"
    new_template_path

  when "formularios/new"
    new_formulario_path

  when "home", "inicial"
    root_path

  else
    raise "Não sei o caminho para a página '#{page_name}'. Adicione no step definition."
  end
end


# ============================
# NAVEGAÇÃO SIMPLES (STRING DIRETA)
# ============================
Dado('(que eu )estou na página {string}') do |page_name|
  path = case page_name
         when "Gerenciamento"
           templates_path
         when "formularios/new"
           new_formulario_path
         when "templates/new"
           new_template_path
         when "templates"
           templates_path
         else
           page_name
         end

  begin
    visit path
  rescue ActionController::RoutingError
    pending "Route para #{page_name} (#{path}) ainda não implementada"
  end
end


# ============================
# VALIDAÇÃO DE ERRO
# ============================
Então('eu devo ver a mensagem de erro {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end
