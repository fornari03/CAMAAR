# =========================================
# Contexto (Dado)
# =========================================

# Cria um template de avaliação para distribuição.
#
# Argumentos:
#   - nome_template (String): Nome do template.
#
# Efeitos Colaterais:
#   - Cria Template e Usuario (se necessário).
Dado('que existe um template de avaliação {string}') do |nome_template|
  admin = Usuario.find_by(ocupacao: :admin) || Usuario.create!(
    nome: 'Admin', email: 'admin@test.com', matricula: '000', 
    usuario: 'admin', password: 'password', ocupacao: :admin, status: true
  )
  
  @template = Template.find_or_create_by!(name: nome_template) do |t|
    t.titulo = nome_template
    t.id_criador = admin.id
    t.participantes = 'todos'
    t.hidden = false
  end
end

# Cria turma com alunos pré-matriculados.
#
# Argumentos:
#   - nome_turma (String): Nome da turma (matéria).
#   - num_alunos (Integer): Quantidade de alunos.
#
# Efeitos Colaterais:
#   - Setup completo de estrutura acadêmica e matrículas.
Dado('que existe a turma {string} com {int} alunos matriculados') do |nome_turma, num_alunos|
  turma = setup_academic_structure(nome_turma)
  enroll_batch_students(turma, num_alunos)
end

# Acessa página de distribuição.
#
# Efeitos Colaterais:
#   - Visita /formularios.
Dado('que eu estou na página de distribuição de formulários') do
  visit formularios_path
end

# =========================================
# Ações (Quando)
# =========================================

# Seleciona template no select.
#
# Argumentos:
#   - nome_template (String): Nome do template.
Quando('eu seleciono o template de avaliação {string}') do |nome_template|
  select nome_template, from: 'template_id'
end

# Seleciona múltiplas turmas para distribuição.
#
# Argumentos:
#   - turma1 (String): Nome da primeira turma.
#   - turma2 (String): Nome da segunda turma.
#
# Efeitos Colaterais:
#   - Marca checkboxes de turmas.
Quando('eu seleciono as turmas para distribuição {string} e {string}') do |turma1, turma2|
  materia1 = Materia.find_by(nome: turma1)
  t1 = Turma.where(materia: materia1).first
  
  materia2 = Materia.find_by(nome: turma2)
  t2 = Turma.where(materia: materia2).first
  
  check "turma_#{t1.id}"
  check "turma_#{t2.id}"
end

# Clica em botão de distribuição.
#
# Argumentos:
#   - nome_botao (String): Nome do botão.
Quando('eu clico no botão de distribuição {string}') do |nome_botao|
  click_button nome_botao
end

# Realiza fluxo completo de distribuição (seleção + clique).
#
# Argumentos:
#   - template (String): Nome do template.
#
# Efeitos Colaterais:
#   - Submete formulário.
Quando('eu seleciono o template {string} e clico em Distribuir') do |template|
  select template, from: 'template_id'
  click_button 'Distribuir Formulário'
end

# =========================================
# Verificações (Então)
# =========================================

# Verifica mensagem de sucesso.
#
# Argumentos:
#   - mensagem (String): Mensagem esperada.
Então('eu devo ver a mensagem de sucesso de distribuição {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

# Verifica mensagem de erro.
#
# Argumentos:
#   - mensagem (String): Mensagem esperada.
Então('eu devo ver a mensagem de erro de distribuição {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

# Verifica associação criada no banco entre Turma e Template (via Formulario).
#
# Argumentos:
#   - nome_turma (String): Nome da turma.
#   - nome_template (String): Nome do template.
#
# Retorno:
#   - (Boolean): Asserção de existência.
Então('a turma {string} deve ter um formulário associado ao template {string}') do |nome_turma, nome_template|
  materia = Materia.find_by(nome: nome_turma)
  turma = Turma.where(materia: materia).first
  template = Template.find_by(name: nome_template)
  
  expect(turma.formularios.where(template: template)).to exist
end

# Verifica criação de respostas pendentes para alunos.
#
# Argumentos:
#   - num_alunos (Integer): Quantidade mínima esperada.
#   - nome_turma (String): Nome da turma.
#
# Retorno:
#   - (Boolean): Asserção de contagem de Resposta.
Então('todos os {int} alunos da turma {string} devem ter uma resposta pendente para este formulário') do |num_alunos, nome_turma|
  materia = Materia.find_by(nome: nome_turma)
  turma = Turma.where(materia: materia).first
  
  form = turma.formularios.last
  expect(Resposta.where(formulario: form, data_submissao: nil).count).to be >= num_alunos
end