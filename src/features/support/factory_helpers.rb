# --- Helpers de Contexto (Step 1) ---

def find_or_create_form_dependencies
  docente = Usuario.find_by(ocupacao: :docente) || create_docente_padrao
  materia = Materia.find_or_create_by!(nome: "Engenharia de Software", codigo: "ES01")
  turma = find_or_create_turma_padrao(docente, materia)
  template = find_or_create_template_padrao(docente)

  { docente: docente, turma: turma, template: template }
end

def create_formulario_relatorio(titulo, contexto)
  Formulario.create!(
    template: contexto[:template],
    turma: contexto[:turma],
    titulo_envio: titulo,
    data_criacao: Time.current,
    data_encerramento: 30.days.from_now
  )
end

# --- Builders de Entidades (Step 1) ---

def create_docente_padrao
  Usuario.create!(
    nome: "Docente Relatorio", email: "doc_rel@test.com", matricula: "DR01", 
    usuario: "doc_rel", password: "password", ocupacao: :docente, status: true
  )
end

def find_or_create_turma_padrao(docente, materia)
  Turma.find_or_create_by!(codigo: "TA", materia: materia) do |t|
    t.semestre = "2025.1"
    t.docente = docente
    t.horario = "24M12"
  end
end

def find_or_create_template_padrao(docente)
  Template.find_or_create_by!(titulo: "Template Padrão") do |t|
    t.name = "Template Padrão"
    t.id_criador = docente.id
    t.participantes = "todos"
  end
end

# --- Helpers de Submissão (Step 2) ---

def create_student_submission(form, index)
  # Cria aluno único
  aluno = create_unique_student(index)
  
  # Matricula na turma do formulário
  Matricula.create!(usuario: aluno, turma: form.turma)
  
  # Cria a resposta
  Resposta.create!(
    formulario: form,
    participante: aluno,
    data_submissao: Time.current
  )
end

def create_unique_student(index)
  unique_id = "#{index}_#{Time.now.to_i}"
  Usuario.create!(
    nome: "Aluno Relatorio #{index}", 
    email: "aluno_rel_#{unique_id}@test.com", 
    matricula: "2025#{unique_id}", 
    usuario: "aluno_rel_#{unique_id}", 
    password: "password", 
    ocupacao: :discente, 
    status: true
  )
end

# --- Infraestrutura Acadêmica ---

def setup_academic_structure(nome_turma)
  materia = find_or_create_materia(nome_turma)
  docente = find_or_create_docente
  find_or_create_turma(materia, docente)
end

def find_or_create_materia(nome)
  Materia.find_or_create_by!(nome: nome) do |m|
    m.codigo = "MAT#{rand(1000..9999)}"
  end
end

def find_or_create_docente
  Usuario.find_by(ocupacao: :docente) || Usuario.create!(
    nome: "Docente #{rand(999)}", 
    email: "doc#{rand(999)}@test.com", 
    matricula: "DOC#{rand(999)}", 
    usuario: "doc#{rand(999)}", 
    password: 'password', 
    ocupacao: :docente, 
    status: true
  )
end

def find_or_create_turma(materia, docente)
  Turma.find_or_create_by!(materia: materia) do |t|
    t.codigo = "T#{rand(100..999)}"
    t.semestre = '2024.1'
    t.horario = '35T'
    t.docente = docente
  end
end

# --- Matrícula de Alunos ---

def enroll_batch_students(turma, quantidade)
  quantidade.times do |i|
    create_and_enroll_single_student(turma, i)
  end
end

def create_and_enroll_single_student(turma, index)
  # Cria o aluno com dados únicos baseados no índice e ID da turma
  aluno = Usuario.create!(
    nome: "Aluno #{index} da #{turma.materia.nome}",
    email: "aluno#{index}_#{turma.id}_#{rand(9999)}@test.com",
    matricula: "2024#{turma.id}#{index}",
    usuario: "user#{turma.id}#{index}",
    password: 'password',
    ocupacao: :discente,
    status: true
  )
  
  # Cria a associação
  Matricula.find_or_create_by!(usuario: aluno, turma: turma)
end

# --- Orquestrador de Criação ---

def create_sigaa_class_structure(full_class_name, docente)
  # Separa o nome da matéria do código da turma
  nome_materia, codigo_turma = parse_class_name_string(full_class_name)

  # Cria ou encontra os registros no banco
  materia = find_or_create_materia_sigaa(nome_materia)
  find_or_create_turma_sigaa(materia, codigo_turma, docente)
end

# --- Parser de String (Lógica Pura) ---

def parse_class_name_string(full_string)
  if full_string.include?(' - ')
    full_string.split(' - ')
  else
    # Retorna o nome original e um código padrão se não houver separador
    [full_string, "A"]
  end
end

# --- Persistência (Banco de Dados) ---

def find_or_create_default_teacher
  Usuario.find_by(ocupacao: :docente) || Usuario.create!(
    nome: "Docente Padrão",
    email: "docente@camaar.unb.br",
    matricula: "DOC123",
    usuario: "docente",
    password: "password",
    ocupacao: :docente,
    status: true
  )
end

def find_or_create_materia_sigaa(nome)
  Materia.find_or_create_by!(nome: nome) do |m|
    # Gera um código fictício baseado nas primeiras letras
    m.codigo = nome[0..3].upcase 
  end
end

def find_or_create_turma_sigaa(materia, codigo_turma, docente)
  Turma.find_or_create_by!(codigo: codigo_turma, materia: materia) do |t|
    t.semestre = "2025.1"
    t.horario = "24M34"
    t.docente = docente
  end
end

# --- Contexto de Infraestrutura ---

def setup_result_view_context
  docente = find_or_create_result_docente
  materia = Materia.find_or_create_by!(nome: "Materia Teste", codigo: "MAT01")
  turma   = find_or_create_result_turma(materia, docente)

  # Retorna um hash para facilitar o acesso nos próximos métodos
  { docente: docente, turma: turma }
end

def find_or_create_result_docente
  Usuario.find_by(ocupacao: :docente) || Usuario.create!(
    nome: "Prof. Teste",
    email: "prof@teste.com",
    matricula: "12345",
    usuario: "prof123",
    password: "password",
    ocupacao: :docente,
    status: true
  )
end

def find_or_create_result_turma(materia, docente)
  Turma.find_or_create_by!(codigo: "T1", materia: materia) do |t|
    t.semestre = "2025.1"
    t.docente = docente
    t.horario = "10h"
  end
end

# --- Criação de Formulários ---

def create_linked_form_and_template(titulo, context)
  # Cria o template vinculado ao docente
  template = create_result_template(titulo, context[:docente])
  
  # Cria o formulário vinculado ao template e à turma
  create_result_formulario(titulo, template, context[:turma])
end

def create_result_template(titulo, docente)
  Template.create!(
    name: titulo,
    titulo: titulo,
    participantes: "todos",
    id_criador: docente.id
  )
end

def create_result_formulario(titulo, template, turma)
  Formulario.create!(
    template: template,
    turma: turma,
    titulo_envio: titulo,
    data_criacao: Time.current,
    data_encerramento: 30.days.from_now
  )
end