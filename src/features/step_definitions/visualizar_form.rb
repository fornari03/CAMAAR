# =========================================
# Contexto (Dado)
# =========================================

Dado('estou matriculado nas turmas {string} e {string}') do |turma1, turma2|
  [turma1, turma2].each do |nome_turma|
    step "estou matriculado na turma \"#{nome_turma}\""
  end
end

Dado('estou matriculado na turma {string}') do |nome_turma|
  create_enrollment_for_current_user(nome_turma)
end

Dado('a turma {string} possui os formulários {string} e {string}') do |nome_turma, form1, form2|
  create_forms_for_class(nome_turma, [form1, form2])
end

Dado('eu já respondi apenas o formulário {string}') do |titulo_formulario|
  mark_specific_form_as_answered(titulo_formulario)
end

Dado('todos os formulários desta turma já foram respondidos por mim') do
  mark_all_pending_responses_as_answered
end

Dado('não estou matriculado em nenhuma turma') do
  clear_student_enrollments
end

# =========================================
# Verificações (Então)
# =========================================

Então('eu devo ver o formulário {string}') do |titulo|
  expect(page).to have_content(titulo)
end

Então('eu não devo ver o formulário {string}') do |titulo|
  expect(page).not_to have_content(titulo)
end

Então('eu devo ver a mensaagem {string}') do |mensagem|
  step "eu devo ver a mensagem \"#{mensagem}\""
end

Então('não devo ver lista de formulários') do
  expect(page).not_to have_css('ul.lista-formularios') 
  expect(page).not_to have_css('table.tabela-formularios')
end

Então('devo permanecer na página {string}') do |page_name|
  expect(page).to have_current_path(path_to(page_name))
end

# =========================================
# Métodos Auxiliares (Helpers)
# =========================================

def create_enrollment_for_current_user(nome_turma)
  docente = Usuario.find_by(ocupacao: :docente) || Usuario.create!(
    nome: "Docente", email: "doc@test.com", matricula: "D01", 
    usuario: "doc", password: "password", ocupacao: :docente, status: true
  )

  materia = Materia.find_or_create_by!(nome: nome_turma) do |m|
    m.codigo = "MAT#{rand(100..999)}"
  end
  
  turma = Turma.find_or_create_by!(materia: materia) do |t|
    t.codigo = "T1"
    t.semestre = "2025.1"
    t.docente = docente
    t.horario = "10h"
  end

  Matricula.find_or_create_by!(usuario: @user, turma: turma)
end

def create_forms_for_class(nome_turma, form_titles)
  materia = Materia.find_by(nome: nome_turma)
  turma = Turma.find_by(materia: materia)
  docente = turma.docente

  form_titles.each do |titulo|
    template = Template.create!(
      name: titulo, 
      titulo: titulo, 
      id_criador: docente.id, 
      participantes: 'todos',
      hidden: false
    )

    form = Formulario.create!(
      template: template,
      turma: turma,
      titulo_envio: titulo,
      data_criacao: Time.current,
      data_encerramento: 30.days.from_now
    )
    
    Resposta.create!(formulario: form, participante: @user, data_submissao: nil)
  end
end

def mark_specific_form_as_answered(titulo_formulario)
  formulario = Formulario.joins(:template).find_by(templates: { titulo: titulo_formulario })
  resposta = Resposta.find_by(formulario: formulario, participante: @user)
  
  resposta.update!(data_submissao: Time.current)
end

def mark_all_pending_responses_as_answered
  @user.respostas.where(data_submissao: nil).update_all(data_submissao: Time.current)
end

def clear_student_enrollments
  @user.matriculas.destroy_all
end