require 'json'

# Setup inicial do cenário.
Before do
  @fake_classes = []
  @fake_members = []
end

# =========================================
# Contexto (Dado)
# =========================================

# Limpa turmas e matérias do sistema.
#
# Efeitos Colaterais:
#   - Remove registros de Turma e Materia.
Dado('que o sistema não possui nenhuma turma cadastrada') do
  Turma.destroy_all
  Materia.destroy_all
end

# Limpa usuários não-admin.
#
# Efeitos Colaterais:
#   - Remove registros de Usuario.
Dado('que o sistema não possui nenhum usuário cadastrado') do
  Usuario.where.not(ocupacao: :admin).destroy_all
end

# Adiciona turma ao mock do SIGAA.
#
# Argumentos:
#   - codigo_turma (String): Código.
#   - nome_materia (String): Nome.
#   - codigo_materia (String): Código Matéria.
#
# Efeitos Colaterais:
#   - Adiciona dados a @fake_classes.
Dado('que o sigaa contém a turma {string} da matéria {string} \({string})') do |codigo_turma, nome_materia, codigo_materia|
  add_class_to_sigaa_mock(codigo_turma, nome_materia, codigo_materia)
end

# Adiciona participante ao mock de turma.
#
# Argumentos:
#   - nome (String): Nome.
#   - matricula (String): Matrícula.
#
# Efeitos Colaterais:
#   - Adiciona membro a @fake_members.
Dado('esta turma contém o participante {string} \({string})') do |nome, matricula|
  contexto = resolve_current_class_context
  member_record = find_or_create_member_record(contexto[:code], contexto[:class_code])
  add_student_to_member_record(member_record, nome, matricula)
end

# Cria usuário discente.
#
# Argumentos:
#   - nome (String): Nome.
#   - matricula (String): Matrícula.
#
# Efeitos Colaterais:
#   - Persiste Usuario.
Dado('que o sistema possui o usuário {string} \({string}) cadastrado') do |nome, matricula|
  create_discente(nome, matricula)
end

# Cria usuário discente com email.
#
# Argumentos:
#   - nome (String): Nome.
#   - matricula (String): Matrícula.
#   - email (String): Email.
#
# Efeitos Colaterais:
#   - Persiste Usuario.
Dado('que o sistema possui o usuário {string} \({string}) cadastrado com o e-mail {string}') do |nome, matricula, email|
  create_discente(nome, matricula, email)
end

# Verifica inexistência de turma.
#
# Argumentos:
#   - nome_turma (String): Nome matéria.
#   - codigo_turma (String): Código turma.
Dado('que o sistema não possui a turma {string} \({string}) cadastrada') do |nome_turma, codigo_turma|
  expect(Turma.joins(:materia).where(materias: { nome: nome_turma }, codigo: codigo_turma).count).to eq(0)
end

# Cria turma completa no sistema.
#
# Argumentos:
#   - codigo_turma (String): Código turma.
#   - nome_materia (String): Nome matéria.
#   - codigo_materia (String): Código matéria.
#
# Efeitos Colaterais:
#   - Persiste Materia, Turma.
Dado('que o sistema possui a turma {string} da matéria {string} \({string}) cadastrada') do |codigo_turma, nome_materia, codigo_materia|
  create_full_system_class(codigo_turma, nome_materia, codigo_materia)
end

# Cria turma com matéria (nome padrão).
#
# Argumentos:
#   - codigo_turma (String): Código turma.
#   - codigo_materia (String): Código matéria.
#
# Efeitos Colaterais:
#   - Persiste Materia, Turma.
Dado('que o sistema possui a turma {string} da matéria {string} cadastrada') do |codigo_turma, codigo_materia|
  create_full_system_class(codigo_turma, "Matéria #{codigo_materia}", codigo_materia)
end

# Cria matéria.
#
# Argumentos:
#   - codigo_materia (String): Código.
#
# Efeitos Colaterais:
#   - Persiste Materia.
Dado('que o sistema possui a matéria {string} cadastrada') do |codigo_materia|
  find_or_create_materia_by_code(codigo_materia)
end

# Verifica inexistência de usuário.
#
# Argumentos:
#   - nome (String): Nome (não usado na busca).
#   - matricula (String): Matrícula.
Dado('que o sistema não possui o usuário {string} \({string}) cadastrado') do |nome, matricula|
  expect(Usuario.where(matricula: matricula).count).to eq(0)
end

# Simula erro no SIGAA mock.
#
# Efeitos Colaterais:
#   - Define flag de erro.
Dado('que o sigaa está indisponível') do
  @simular_erro_arquivo = true
end

# Atualiza email no mock.
#
# Argumentos:
#   - matricula (String): Matrícula.
#   - novo_email (String): Novo email.
#
# Efeitos Colaterais:
#   - Modifica mock de aluno.
Dado('a fonte de dados externa indica que o e-mail de {string} agora é {string}') do |matricula, novo_email|
  matricula_str = matricula.to_s
  turma_mock = find_or_create_mock_class_for(matricula_str)
  ensure_class_definition_exists(turma_mock["code"])
  update_mock_student_email(turma_mock, matricula_str, novo_email)
end

# Verifica que usuário não está matriculado.
#
# Argumentos:
#   - matricula_usuario (String): Matrícula usuário.
#   - codigo_turma (String): Código turma.
#   - codigo_materia (String): Código matéria.
Dado('o usuário {string} ainda não está matriculado na turma {string} da matéria {string}') do |matricula_usuario, codigo_turma, codigo_materia|
  verify_user_not_enrolled(matricula_usuario, codigo_turma, codigo_materia)
end

# Define matrícula no mock.
#
# Argumentos:
#   - matricula (String): Aluno.
#   - codigo_turma (String): Turma.
#   - codigo_materia (String): Matéria.
#
# Efeitos Colaterais:
#   - Cria estrutura mockada se não existir.
Dado('a fonte de dados externa indica que {string} está matriculado na turma {string} da matéria {string}') do |matricula, codigo_turma, codigo_materia|
  ensure_imported_class_definition(codigo_materia, codigo_turma)
  create_class_with_student_if_missing(codigo_materia, codigo_turma, matricula)
end

# Atualiza nome no mock.
#
# Argumentos:
#   - matricula (String): Matrícula.
#   - novo_nome (String): Novo nome.
Dado('a fonte de dados externa indica que o nome de {string} agora é {string}') do |matricula, novo_nome|
  ensure_class_definition_exists("CIC0097")
  turma_mock = ensure_default_class_member_exists
  upsert_student_with_name(turma_mock, matricula, novo_nome)
end

# Atualiza nome da matéria no mock.
#
# Argumentos:
#   - codigo_materia (String): Código.
#   - novo_nome (String): Novo nome.
Dado('a fonte de dados externa indica que o nome da matéria {string} agora é {string}') do |codigo_materia, novo_nome|
  update_sigaa_subject_name(codigo_materia, novo_nome)
end

# Remove dados do mock.
#
# Argumentos:
#   - identificador (String): Código ou matrícula.
Dado('a fonte de dados externa indica que {string} não está mais presente') do |identificador|
  remove_mock_class_data(identificador)
  remove_mock_student_data(identificador)
end

# =========================================
# Ações (Quando)
# =========================================

# Dispara importação via UI.
#
# Argumentos:
#   - botao (String): Texto do botão.
#
# Efeitos Colaterais:
#   - Mocka FS, clica botão, realiza POST.
Quando('eu solicito a importação clicando em {string}') do |botao|
  capture_initial_database_counts
  setup_file_system_mocking
  click_button botao
end

# =========================================
# Verificações (Então)
# =========================================

# Verifica existência da turma.
#
# Argumentos:
#   - codigo_turma (String): Turma.
#   - nome_materia (String): Matéria.
#   - codigo_materia (String): Código Matéria.
Então('a turma {string} da matéria {string} \({string}) deve ser cadastrada no sistema') do |codigo_turma, nome_materia, codigo_materia|
  verify_class_existence(codigo_turma, nome_materia, codigo_materia)
end

# Verifica existência do usuário.
#
# Argumentos:
#   - nome (String): Nome.
#   - matricula (String): Matrícula.
Então('o usuário {string} \({string}) deve ser cadastrado no sistema') do |nome, matricula|
  verify_user_existence(nome, matricula)
end

# Verifica consistência de matrícula.
#
# Argumentos:
#   - matricula (String): Aluno.
#   - codigo_turma (String): Turma.
#   - codigo_materia (String): Matéria.
Então('o usuário {string} deve estar matriculado na turma {string} da matéria {string}') do |matricula, codigo_turma, codigo_materia|
  verify_enrollment_consistency(matricula, codigo_turma, codigo_materia)
end

# Alias para verificação de matrícula.
Então('o usuário {string} deve ser matriculado na turma {string} da matéria {string}') do |matricula, codigo_turma, codigo_materia|
  verify_enrollment_consistency(matricula, codigo_turma, codigo_materia)
end

# Verifica mensagem de sucesso.
#
# Argumentos:
#   - mensagem (String): Mensagem.
Então('eu devo ver a mensagem de sucesso {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

# Verifica que contagem de turmas não mudou.
Então('nenhuma nova turma deve ser cadastrada no sistema') do
  expect(Turma.count).to eq(@quantidade_inicial_turmas)
end

# Verifica que contagem de usuários não mudou.
Então('nenhum novo usuário deve ser cadastrado no sistema') do
  expect(Usuario.count).to eq(@quantidade_inicial_usuarios)
end

# Verifica unicidade de usuário.
#
# Argumentos:
#   - nome (String): Nome (ignorado).
#   - matricula (String): Matrícula.
Então('o usuário {string} \({string}) não deve ser duplicado no sistema') do |nome, matricula|
  expect(Usuario.where(matricula: matricula).count).to eq(1)
end

# Verifica ausência geral de duplicatas.
Então('nenhum usuário duplicado deve ser criado') do
  duplicados = Usuario.group(:matricula).having('COUNT(*) > 1').count
  expect(duplicados).to be_empty
end

# Verifica estado da UI após ação.
#
# Efeitos Colaterais:
#   - Asserções de UI.
Então('os outro botões na página devem ser liberados') do
  verify_edit_button_active
  verify_navigation_links_active
end

# Verifica atualização de email.
#
# Argumentos:
#   - matricula (String): Matrícula.
#   - novo_email (String): Novo email.
Então('o e-mail do usuário {string} deve ser atualizado para {string}') do |matricula, novo_email|
  usuario = Usuario.find_by(matricula: matricula)
  expect(usuario).to be_present
  expect(usuario.email).to eq(novo_email)
end

# Verifica atualização de nome de usuário.
#
# Argumentos:
#   - matricula (String): Matrícula.
#   - novo_nome (String): Novo nome.
Então('o nome do usuário {string} deve ser atualizado para {string}') do |matricula, novo_nome|
  usuario = Usuario.find_by(matricula: matricula)
  expect(usuario).to be_present
  expect(usuario.nome).to eq(novo_nome)
end

# Verifica atualização de nome da matéria.
#
# Argumentos:
#   - codigo_materia (String): Código.
#   - novo_nome (String): Novo nome.
Então('o nome da matéria {string} deve ser atualizado para {string}') do |codigo_materia, novo_nome|
  materia = Materia.find_by(codigo: codigo_materia)
  expect(materia).to be_present
  expect(materia.nome).to eq(novo_nome)
end

# Verifica exclusão de usuário.
#
# Argumentos:
#   - matricula (String): Matrícula.
Então('o usuário {string} deve ser excluído do sistema') do |matricula|
  expect(Usuario.find_by(matricula: matricula)).to be_nil
end

# =========================================
# Métodos Auxiliares (Helpers)
# =========================================

# Adiciona turma mock SIGAA.
#
# Argumentos:
#   - codigo_turma (String): Código turma.
#   - nome_materia (String): Nome matéria.
#   - codigo_materia (String): Código matéria.
def add_class_to_sigaa_mock(codigo_turma, nome_materia, codigo_materia)
  @fake_classes << {
    "name" => nome_materia,
    "code" => codigo_materia,
    "class" => {
      "classCode" => codigo_turma,
      "semester" => "2024.1",
      "time" => "35T23"
    }
  }
end

# Cria discente no sistema.
#
# Argumentos:
#   - nome (String): Nome.
#   - matricula (String): Matrícula.
#   - email (String): Email (opcional).
def create_discente(nome, matricula, email = nil)
  email ||= "#{matricula}@exemplo.com"
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

# Cria estrutura completa de turma/materia/docente.
#
# Argumentos:
#   - codigo_turma (String): Código.
#   - nome_materia (String): Nome.
#   - codigo_materia (String): Código.
def create_full_system_class(codigo_turma, nome_materia, codigo_materia)
  materia = find_or_create_materia_by_code(codigo_materia, nome_materia)
  docente = find_or_create_default_docente
  
  Turma.find_or_create_by!(codigo: codigo_turma) do |t|
    t.materia = materia
    t.docente = docente
    t.semestre = "2024.1"
    t.horario = "35T23"
  end
end

# Cria matéria por código.
#
# Argumentos:
#   - codigo (String): Código.
#   - nome (String): Nome (opcional).
def find_or_create_materia_by_code(codigo, nome = nil)
  Materia.find_or_create_by!(codigo: codigo) do |m|
    m.nome = nome || "Matéria #{codigo}"
  end
end

# Cria docente padrão.
#
# Retorno:
#   - (Usuario): Docente default.
def find_or_create_default_docente
  Usuario.find_by(ocupacao: :docente) || Usuario.create!(
    nome: "Professor Teste",
    matricula: "999999",
    usuario: "999999",
    email: "prof_teste_local@unb.br",
    password: "123",
    ocupacao: :docente,
    status: true
  )
end

# Atualiza nome de matéria mock SIGAA.
#
# Argumentos:
#   - codigo_materia (String): Código.
#   - novo_nome (String): Novo nome.
def update_sigaa_subject_name(codigo_materia, novo_nome)
  class_mock = @fake_classes.find { |c| c["code"] == codigo_materia }

  unless class_mock
    class_mock = {
      "code" => codigo_materia,
      "name" => "Nome Antigo",
      "class" => { "semester" => "2024.1", "time" => "35T23", "classCode" => "TA" }
    }
    @fake_classes << class_mock
  end

  class_mock["name"] = novo_nome
end

# Verifica existência de turma e relação com matéria.
#
# Argumentos:
#   - codigo_turma (String): Código turma.
#   - nome_materia (String): Nome matéria.
#   - codigo_materia (String): Código matéria.
def verify_class_existence(codigo_turma, nome_materia, codigo_materia)
  materia = Materia.find_by(codigo: codigo_materia)
  turma = Turma.joins(:materia).find_by(codigo: codigo_turma, materia: materia)
  expect(turma).to be_present
  expect(turma.materia.nome).to eq(nome_materia)
end

# Verifica existência de usuário.
#
# Argumentos:
#   - nome (String): Nome.
#   - matricula (String): Matrícula.
def verify_user_existence(nome, matricula)
  usuario = Usuario.find_by(matricula: matricula)
  expect(usuario).to be_present
  expect(usuario.nome).to eq(nome)
end

# Verifica que usuário NÃO está na turma.
#
# Argumentos:
#   - matricula_usuario (String): Matrícula.
#   - codigo_turma (String): Código turma.
#   - codigo_materia (String): Código matéria.
def verify_user_not_enrolled(matricula_usuario, codigo_turma, codigo_materia)
  user = Usuario.find_by(matricula: matricula_usuario)
  turma = Turma.joins(:materia).find_by(codigo: codigo_turma, materias: { codigo: codigo_materia })

  if turma
    expect(user.turmas).not_to include(turma)
  end
end