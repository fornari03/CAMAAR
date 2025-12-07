

Dado('existem as turmas {string} e {string} importadas do SIGAA') do |string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end



Quando('eu seleciono o template {string}') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Quando('eu seleciono as turmas {string} e {string}') do |string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Quando('eu defino a data de encerramento para {string}') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Então('eu devo ser redirecionado para a página {string}') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

# Pending steps added
Então('o formulário deve estar associado ao template {string}') do |template_name|
  pending "Assertion for form-template association not implemented"
end

Então('o formulário deve estar associado ao docente atual') do
  pending "Assertion for form-docente association not implemented"
end

Então('o formulário deve estar marcado como criado por {string}') do |role|
  pending "Assertion for form creator role #{role} not implemented"
end

Dado('eu sou responsável pelas turmas {string}') do |turmas|
  pending "Step to assign responsibility for turmas #{turmas} not implemented"
end

Então('eu devo permanecer na página {string}') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Então('eu devo ver a mensagem de erro {string}') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end