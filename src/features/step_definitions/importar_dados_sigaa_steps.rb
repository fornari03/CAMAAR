require 'json'

Before do
  @fake_classes = []
  @fake_members = []
end

# =========================================
# Contexto (Dado)
# =========================================

Dado('que o sistema não possui nenhuma turma cadastrada') do
  Turma.destroy_all
  Materia.destroy_all
end

Dado('que o sistema não possui nenhum usuário cadastrado') do
  Usuario.where.not(ocupacao: :admin).destroy_all
end

Dado('que o sigaa contém a turma {string} da matéria {string} \({string})') do |codigo_turma, nome_materia, codigo_materia|
  add_class_to_sigaa_mock(codigo_turma, nome_materia, codigo_materia)
end

Dado('esta turma contém o participante {string} \({string})') do |nome, matricula|
  contexto = resolve_current_class_context
  member_record = find_or_create_member_record(contexto[:code], contexto[:class_code])
  add_student_to_member_record(member_record, nome, matricula)
end

Dado('que o sistema possui o usuário {string} \({string}) cadastrado') do |nome, matricula|
  create_discente(nome, matricula)
end

Dado('que o sistema possui o usuário {string} \({string}) cadastrado com o e-mail {string}') do |nome, matricula, email|
  create_discente(nome, matricula, email)
end

Dado('que o sistema não possui a turma {string} \({string}) cadastrada') do |nome_turma, codigo_turma|
  expect(Turma.joins(:materia).where(materias: { nome: nome_turma }, codigo: codigo_turma).count).to eq(0)
end

Dado('que o sistema possui a turma {string} da matéria {string} \({string}) cadastrada') do |codigo_turma, nome_materia, codigo_materia|
  create_full_system_class(codigo_turma, nome_materia, codigo_materia)
end

Dado('que o sistema possui a turma {string} da matéria {string} cadastrada') do |codigo_turma, codigo_materia|
  # Cria com nome padrão
  create_full_system_class(codigo_turma, "Matéria #{codigo_materia}", codigo_materia)
end

Dado('que o sistema possui a matéria {string} cadastrada') do |codigo_materia|
  find_or_create_materia_by_code(codigo_materia)
end

Dado('que o sistema não possui o usuário {string} \({string}) cadastrado') do |nome, matricula|
  expect(Usuario.where(matricula: matricula).count).to eq(0)
end

Dado('que o sigaa está indisponível') do
  @simular_erro_arquivo = true
end

Dado('a fonte de dados externa indica que o e-mail de {string} agora é {string}') do |matricula, novo_email|
  matricula_str = matricula.to_s
  turma_mock = find_or_create_mock_class_for(matricula_str)
  ensure_class_definition_exists(turma_mock["code"])
  update_mock_student_email(turma_mock, matricula_str, novo_email)
end

Dado('o usuário {string} ainda não está matriculado na turma {string} da matéria {string}') do |matricula_usuario, codigo_turma, codigo_materia|
  verify_user_not_enrolled(matricula_usuario, codigo_turma, codigo_materia)
end

Dado('a fonte de dados externa indica que {string} está matriculado na turma {string} da matéria {string}') do |matricula, codigo_turma, codigo_materia|
  ensure_imported_class_definition(codigo_materia, codigo_turma)
  create_class_with_student_if_missing(codigo_materia, codigo_turma, matricula)
end

Dado('a fonte de dados externa indica que o nome de {string} agora é {string}') do |matricula, novo_nome|
  ensure_class_definition_exists("CIC0097")
  turma_mock = ensure_default_class_member_exists
  upsert_student_with_name(turma_mock, matricula, novo_nome)
end

Dado('a fonte de dados externa indica que o nome da matéria {string} agora é {string}') do |codigo_materia, novo_nome|
  update_sigaa_subject_name(codigo_materia, novo_nome)
end

Dado('a fonte de dados externa indica que {string} não está mais presente') do |identificador|
  remove_mock_class_data(identificador)
  remove_mock_student_data(identificador)
end

# =========================================
# Ações (Quando)
# =========================================

Quando('eu solicito a importação clicando em {string}') do |botao|
  capture_initial_database_counts
  setup_file_system_mocking
  click_button botao
end

# =========================================
# Verificações (Então)
# =========================================

Então('a turma {string} da matéria {string} \({string}) deve ser cadastrada no sistema') do |codigo_turma, nome_materia, codigo_materia|
  verify_class_existence(codigo_turma, nome_materia, codigo_materia)
end

Então('o usuário {string} \({string}) deve ser cadastrado no sistema') do |nome, matricula|
  verify_user_existence(nome, matricula)
end

Então('o usuário {string} deve estar matriculado na turma {string} da matéria {string}') do |matricula, codigo_turma, codigo_materia|
  verify_enrollment_consistency(matricula, codigo_turma, codigo_materia)
end

Então('o usuário {string} deve ser matriculado na turma {string} da matéria {string}') do |matricula, codigo_turma, codigo_materia|
  verify_enrollment_consistency(matricula, codigo_turma, codigo_materia)
end

Então('eu devo ver a mensagem de sucesso {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('nenhuma nova turma deve ser cadastrada no sistema') do
  expect(Turma.count).to eq(@quantidade_inicial_turmas)
end

Então('nenhum novo usuário deve ser cadastrado no sistema') do
  expect(Usuario.count).to eq(@quantidade_inicial_usuarios)
end

Então('o usuário {string} \({string}) não deve ser duplicado no sistema') do |nome, matricula|
  expect(Usuario.where(matricula: matricula).count).to eq(1)
end

Então('nenhum usuário duplicado deve ser criado') do
  duplicados = Usuario.group(:matricula).having('COUNT(*) > 1').count
  expect(duplicados).to be_empty
end

Então('os outro botões na página devem ser liberados') do
  verify_edit_button_active
  verify_navigation_links_active
end

Então('o e-mail do usuário {string} deve ser atualizado para {string}') do |matricula, novo_email|
  usuario = Usuario.find_by(matricula: matricula)
  expect(usuario).to be_present
  expect(usuario.email).to eq(novo_email)
end

Então('o nome do usuário {string} deve ser atualizado para {string}') do |matricula, novo_nome|
  usuario = Usuario.find_by(matricula: matricula)
  expect(usuario).to be_present
  expect(usuario.nome).to eq(novo_nome)
end

Então('o nome da matéria {string} deve ser atualizado para {string}') do |codigo_materia, novo_nome|
  materia = Materia.find_by(codigo: codigo_materia)
  expect(materia).to be_present
  expect(materia.nome).to eq(novo_nome)
end

Então('o usuário {string} deve ser excluído do sistema') do |matricula|
  expect(Usuario.find_by(matricula: matricula)).to be_nil
end

# =========================================
# Métodos Auxiliares (Helpers)
# =========================================

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

def find_or_create_materia_by_code(codigo, nome = nil)
  Materia.find_or_create_by!(codigo: codigo) do |m|
    m.nome = nome || "Matéria #{codigo}"
  end
end

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

def verify_class_existence(codigo_turma, nome_materia, codigo_materia)
  materia = Materia.find_by(codigo: codigo_materia)
  turma = Turma.joins(:materia).find_by(codigo: codigo_turma, materia: materia)
  expect(turma).to be_present
  expect(turma.materia.nome).to eq(nome_materia)
end

def verify_user_existence(nome, matricula)
  usuario = Usuario.find_by(matricula: matricula)
  expect(usuario).to be_present
  expect(usuario.nome).to eq(nome)
end

def verify_user_not_enrolled(matricula_usuario, codigo_turma, codigo_materia)
  user = Usuario.find_by(matricula: matricula_usuario)
  turma = Turma.joins(:materia).find_by(codigo: codigo_turma, materias: { codigo: codigo_materia })

  if turma
    expect(user.turmas).not_to include(turma)
  end
end