# Step pendente coordenador.
#
# Argumentos:
#   - string (String): Depto.
Dado('que eu sou um Administrador coordenador do departamento {string} \(CIC)') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

# Step pendente login.
Dado('que estou logado no sistema') do
  pending # Write code here that turns the phrase above into concrete actions
end

# Step pendente turma CIC.
#
# Argumentos:
#   - string (String): Turma.
#   - string2 (String): Depto.
Dado('que existe a turma {string} \(CIC0105) pertencente ao departamento {string}') do |string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

# Step pendente turma MAT.
#
# Argumentos:
#   - string (String): Turma.
#   - string2 (String): Depto.
Dado('que existe a turma {string} \(MAT0025) pertencente ao departamento {string} \(MAT)') do |string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

# Step pendente acesso lista.
Quando('eu acesso a lista de turmas para gerenciamento') do
  pending # Write code here that turns the phrase above into concrete actions
end

# Step pendente ver turma.
#
# Argumentos:
#   - string (String): Turma.
Então('eu devo ver a turma {string} na lista') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

# Step pendente opção de turma.
#
# Argumentos:
#   - string (String): Opção.
#   - string2 (String): Turma.
Então('eu devo ver a opção de {string} para a turma {string}') do |string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

# Step pendente não ver turma.
#
# Argumentos:
#   - string (String): Turma.
Então('eu NÃO devo ver a turma {string} na lista') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

# Step pendente acesso direto.
#
# Argumentos:
#   - string (String): Turma.
Quando('eu tento acessar diretamente a URL de gerenciamento da turma {string}') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end
