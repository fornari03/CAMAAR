Dado('que o usuário {string} \({string}) já existe no sistema com o e-mail {string}') do |nome, matricula, email|
  Usuario.create!(
      nome: nome,
      matricula: matricula,
      usuario: matricula,
      email: email,
      password: 'password123',
      ocupacao: :discente,
      status: true
    )
end

Dado('a fonte de dados externa indica que o e-mail de {string} agora é {string}') do |matricula, novo_email|
  membro = @fake_members.flat_map { |t| t["dicente"] }.find { |d| d["matricula"] == matricula }
  
  # Se não achou no mock (porque o step anterior não criou), cria um mock básico
  unless membro
    # ... lógica de criar mock se necessário, mas idealmente já deve existir
  end
  
  membro["email"] = novo_email
end

Então('o e-mail do usuário {string} deve ser atualizado para {string}') do |matricula, novo_email|
  usuario = Usuario.find_by(matricula: matricula)
  expect(usuario.email).to eq(novo_email)
end

Então('nenhum usuário duplicado deve ser criado') do
  expect(Usuario.where(matricula: "150084006").count).to eq(1)
end

Dado('que o usuário {string} \({string}) já existe no sistema') do |string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Dado('a turma {string} \({string}) também já existe no sistema') do |string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Dado('o usuário {string} ainda não está matriculado na turma {string}') do |string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Dado('a fonte de dados externa indica que {string} está matriculado em {string}') do |string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Então('o usuário {string} deve ser matriculado na turma {string}') do |string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Dado('que o usuário {string} \({string}) já existe no sistema com o nome {string}') do |string, string2, string3|
  pending # Write code here that turns the phrase above into concrete actions
end

Dado('a fonte de dados externa indica que o nome de {string} agora é {string}') do |string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Então('o nome do usuário {string} deve ser atualizado para {string}') do |string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Dado('que a turma {string} \({string}) já existe no sistema com o nome {string}') do |string, string2, string3|
  pending # Write code here that turns the phrase above into concrete actions
end

Dado('a fonte de dados externa indica que o nome da turma {string} agora é {string}') do |string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Então('o nome da turma {string} deve ser atualizado para {string}') do |string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Dado('a fonte de dados externa indica que {string} não está mais presente') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Então('o usuário {string} deve ser desativado no sistema') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Dado('que a turma {string} \({string}) já existe no sistema') do |string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Então('a turma {string} deve ser desativada no sistema') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Dado('que o usuário {string} \({string}) já existe no sistema com o e-mail {string} e o nome {string}') do |string, string2, string3, string4|
  pending # Write code here that turns the phrase above into concrete actions
end

Dado('a fonte de dados externa indica que o e-mail de {string} agora é {string} e o nome agora é {string}') do |string, string2, string3|
  pending # Write code here that turns the phrase above into concrete actions
end