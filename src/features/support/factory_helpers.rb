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