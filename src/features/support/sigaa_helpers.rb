# --- Helpers para Mock de Dados Externos ---

# Encontra ou cria estrutura de turma baseada na matrícula.
#
# Argumentos:
#   - matricula (String): Matrícula para busca.
#
# Retorno:
#   - (Hash): Dados da turma mockada.
def find_or_create_mock_class_for(matricula)
  # Tenta achar turma onde o aluno já está
  existing_class = @fake_members.find { |m| m["dicente"]&.any? { |d| d["matricula"].to_s == matricula } }
  return existing_class if existing_class

  # Se não achar, usa ou cria a turma padrão
  default_class = @fake_members.find { |m| m["code"] == "CIC0097" } || build_default_member_structure
  
  @fake_members << default_class unless @fake_members.include?(default_class)
  default_class
end

# Garante a existência da definição de uma classe no mock.
#
# Argumentos:
#   - code (String): Código da disciplina.
#
# Efeitos Colaterais:
#   - Adiciona entrada em @fake_classes.
def ensure_class_definition_exists(code)
  return if @fake_classes.any? { |c| c["code"] == code }

  @fake_classes << {
    "name" => "Matéria Mock",
    "code" => code,
    "class" => { "semester" => "2024.1", "time" => "35T23", "classCode" => "TA" }
  }
end

# Atualiza email do aluno no mock.
#
# Argumentos:
#   - turma_mock (Hash): Estrutura da turma.
#   - matricula (String): Matrícula alvo.
#   - email (String): Novo email.
#
# Efeitos Colaterais:
#   - Modifica a lista de discentes da turma.
def update_mock_student_email(turma_mock, matricula, email)
  # Remove ocorrências antigas para evitar duplicidade
  @fake_members.each do |t|
    t["dicente"]&.reject! { |d| d["matricula"].to_s == matricula }
  end

  # Adiciona o dado atualizado
  turma_mock["dicente"] << build_student_structure(matricula, email)
end

# --- Construtores de Estrutura de Dados (Factory Methods) ---

# Constrói estrutura padrão de membro.
#
# Retorno:
#   - (Hash): Estrutura mock.
def build_default_member_structure
  {
    "code" => "CIC0097",
    "classCode" => "TA",
    "semester" => "2024.1",
    "dicente" => [],
    "docente" => { "nome" => "Prof Mock", "usuario" => "999", "email" => "mock@email" }
  }
end

# Constrói estrutura de dados de aluno.
#
# Argumentos:
#   - matricula (String): Matrícula.
#   - email (String): Email.
#
# Retorno:
#   - (Hash): Dados do aluno.
def build_student_structure(matricula, email)
  {
    "nome" => "Nome Genérico",
    "matricula" => matricula,
    "usuario" => matricula,
    "email" => email,
    "ocupacao" => "dicente"
  }
end

# Verifica se o botão de editar templates está ativo.
#
# Efeitos Colaterais:
#   - Realiza asserções de UI.
def verify_edit_button_active
  # Verifica especificamente o botão de formulário (button_to)
  botao = find_button("Editar Templates")
  expect(botao).not_to be_disabled
  expect(botao[:class]).to include("bg-green-500")
end

# Verifica links de navegação.
#
# Efeitos Colaterais:
#   - Realiza asserções de UI.
def verify_navigation_links_active
  # Verifica os elementos de navegação (link_to)
  links = ["Enviar Formularios", "Resultados"]
  
  links.each do |texto|
    link = find_link(texto)
    expect(link).to be_present
    expect(link[:class]).to include("bg-green-500")
  end
end

# Atualiza o nome do aluno no mock de membros
#
# Argumentos:
#   - matricula (String): Matrícula do aluno.
#   - novo_nome (String): Novo nome a ser definido.
def update_mock_student_name(matricula, novo_nome)
  # Procura o aluno em @fake_members. Se não achar, cria um padrão (reuso da lógica anterior)
  turma_mock = find_or_create_mock_class_for(matricula)
  
  # Encontra o registro do aluno dentro da lista de discentes
  aluno = turma_mock["dicente"]&.find { |d| d["matricula"].to_s == matricula.to_s }

  if aluno
    # Se o aluno já existe, apenas atualiza o nome
    aluno["nome"] = novo_nome
  else
    # Se o aluno não existe na lista, cria um novo registro com o nome atualizado
    # (Reaproveita o builder do passo anterior, alterando o nome)
    novo_aluno = build_student_structure(matricula, "email@padrao.com")
    novo_aluno["nome"] = novo_nome
    turma_mock["dicente"] << novo_aluno
  end
end

# Garante que um membro padrão existe na lista mockada.
#
# Retorno:
#   - (Hash): Dados da turma.
def ensure_default_class_member_exists
  code = "CIC0097"
  class_code = "TA"

  # Tenta encontrar a turma existente
  turma = @fake_members.find { |m| m["code"] == code && m["classCode"] == class_code }
  return turma if turma

  # Cria a turma padrão se não encontrar
  new_turma = {
    "code" => code,
    "classCode" => class_code,
    "semester" => "2024.1",
    "dicente" => [],
    "docente" => { "nome" => "Prof Mock", "usuario" => "999", "email" => "mock@email" }
  }
  
  @fake_members << new_turma
  new_turma
end

# Atualiza ou insere aluno com novo nome.
#
# Argumentos:
#   - turma_mock (Hash): Turma alvo.
#   - matricula (String): Matrícula.
#   - novo_nome (String): Nome atualizado.
def upsert_student_with_name(turma_mock, matricula, novo_nome)
  matricula_str = matricula.to_s

  # Remove qualquer registro anterior dessa matrícula para evitar duplicação
  turma_mock["dicente"].reject! { |d| d["matricula"].to_s == matricula_str }

  # Adiciona o registro atualizado
  turma_mock["dicente"] << {
    "nome" => novo_nome,
    "matricula" => matricula_str,
    "usuario" => matricula_str,
    "email" => "#{matricula_str}@aluno.unb.br", # Mantém a lógica original do seu snippet
    "ocupacao" => "dicente"
  }
end

# Resolve contexto atual da classe.
#
# Retorno:
#   - (Hash): { code, class_code }.
def resolve_current_class_context
  last_class = @fake_classes.last
  {
    code: last_class["code"],
    class_code: last_class["class"]["classCode"]
  }
end

# --- Infraestrutura (Membros) ---

# Encontra ou cria registro de membro.
#
# Argumentos:
#   - code (String): Código da disciplina.
#   - class_code (String): Código da turma.
#
# Retorno:
#   - (Hash): Dados do membro.
def find_or_create_member_record(code, class_code)
  record = @fake_members.find { |m| m["code"] == code && m["classCode"] == class_code }
  return record if record

  create_default_member_record(code, class_code)
end

# Cria registro padrão de membro.
#
# Argumentos:
#   - code (String): Disciplina.
#   - class_code (String): Turma.
#
# Retorno:
#   - (Hash): Dados criados.
def create_default_member_record(code, class_code)
  new_record = {
    "code" => code,
    "classCode" => class_code,
    "semester" => "2024.1",
    "dicente" => [],
    "docente" => default_teacher_structure
  }
  @fake_members << new_record
  new_record
end

# Estrutura padrão de docente.
#
# Retorno:
#   - (Hash): Dados do docente.
def default_teacher_structure
  {
    "nome" => "Professor Mock",
    "usuario" => "99999",
    "email" => "prof@mock.com",
    "ocupacao" => "docente"
  }
end

# --- Ação (Adicionar Aluno) ---

# Adiciona aluno ao registro de membro.
#
# Argumentos:
#   - record (Hash): Registro alvo.
#   - nome (String): Nome do aluno.
#   - matricula (String): Matrícula.
def add_student_to_member_record(record, nome, matricula)
  # Evita duplicatas removendo registro anterior se existir
  record["dicente"].reject! { |d| d["matricula"] == matricula }
  
  # Adiciona o novo
  record["dicente"] << build_student_hash(nome, matricula)
end

# Constrói hash de aluno.
#
# Retorno:
#   - (Hash): Dados do aluno.
def build_student_hash(nome, matricula)
  {
    "nome" => nome,
    "matricula" => matricula,
    "usuario" => matricula,
    "email" => "#{matricula}@aluno.unb.br",
    "ocupacao" => "dicente" # Mantendo a grafia 'dicente' do seu código original
  }
end

# Captura contagens iniciais do banco.
#
# Efeitos Colaterais:
#   - Define variáveis de instância @quantidade_inicial_*.
def capture_initial_database_counts
  @quantidade_inicial_turmas = Turma.count 
  @quantidade_inicial_usuarios = Usuario.count
end

# Configura mock de sistema de arquivos.
#
# Efeitos Colaterais:
#   - Mocka File.read para retornar JSONs falsos.
def setup_file_system_mocking
  # Usa and_wrap_original para interceptar apenas os arquivos que queremos
  allow(File).to receive(:read).and_wrap_original do |original_method, *args|
    handle_file_read_interception(original_method, args)
  end
end

# Interceptador de leitura de arquivo.
#
# Argumentos:
#   - original_method (Method): Método original File.read.
#   - args (Array): Argumentos da chamada.
#
# Retorno:
#   - (String): Conteúdo JSON ou resultado original.
def handle_file_read_interception(original_method, args)
  # 1. Simulação de Erro (se flag estiver ativa)
  raise Errno::ENOENT if @simular_erro_arquivo

  path = args.first.to_s
  
  # 2. Retorna JSON mockado dependendo do caminho do arquivo
  if path.include?('classes.json')
    @fake_classes.to_json
  elsif path.include?('class_members.json')
    @fake_members.to_json
  else
    # 3. Se não for um dos nossos arquivos, deixa o Ruby ler normalmente
    original_method.call(*args)
  end
end

# --- Manipulação de @fake_classes ---

# Garante definição de classe importada.
#
# Argumentos:
#   - codigo_materia (String): Código da matéria.
#   - codigo_turma (String): Código da turma.
def ensure_imported_class_definition(codigo_materia, codigo_turma)
  return if @fake_classes.any? { |c| c["code"] == codigo_materia }

  @fake_classes << {
    "name" => "Matéria Importada",
    "code" => codigo_materia,
    "class" => { "semester" => "2024.1", "time" => "35T23", "classCode" => codigo_turma }
  }
end

# --- Manipulação de @fake_members ---

# Cria classe com aluno se faltar.
#
# Argumentos:
#   - codigo_materia (String): Disciplina.
#   - codigo_turma (String): Turma.
#   - matricula (String): Aluno.
def create_class_with_student_if_missing(codigo_materia, codigo_turma, matricula)
  # Verifica se a turma já existe
  exists = @fake_members.any? { |m| m["code"] == codigo_materia && m["classCode"] == codigo_turma }
  return if exists # Mantém a lógica do 'unless turma_mock' original

  # Constrói a nova estrutura
  new_turma = build_import_member_structure(codigo_materia, codigo_turma)
  
  # Adiciona o aluno à estrutura criada
  new_turma["dicente"] << build_imported_student_hash(matricula)

  # Persiste na lista mockada
  @fake_members << new_turma
end

# --- Builders (Fábricas de Hash) ---

# Estrutura base de membro.
#
# Retorno:
#   - (Hash): Dados da turma.
def build_import_member_structure(code, class_code)
  {
    "code" => code,
    "classCode" => class_code,
    "semester" => "2024.1",
    "dicente" => [],
    "docente" => { "nome" => "Prof Mock", "usuario" => "999", "email" => "mock@email" }
  }
end

# Estrutura base de aluno importado.
#
# Retorno:
#   - (Hash): Dados do aluno.
def build_imported_student_hash(matricula)
  matricula_str = matricula.to_s
  {
    "nome" => "Aluno Importado",
    "matricula" => matricula_str,
    "usuario" => matricula_str,
    "email" => "#{matricula_str}@aluno.unb.br",
    "ocupacao" => "dicente"
  }
end

# Remove dados mockados de classe.
#
# Argumentos:
#   - code (String): Código da matéria.
def remove_mock_class_data(code)
  # Remove a definição da classe
  @fake_classes.reject! { |c| c["code"] == code }
  
  # Remove a lista de membros associada àquela matéria
  @fake_members.reject! { |m| m["code"] == code }
end

# Remove dados de aluno de todos os pontos.
#
# Argumentos:
#   - matricula (String): Matrícula.
def remove_mock_student_data(matricula)
  id_str = matricula.to_s
  
  # Itera sobre todas as turmas para remover o aluno de onde ele estiver
  @fake_members.each do |turma|
    # Usa safe navigation (&.) para evitar erro caso a chave 'dicente' não exista
    turma["dicente"]&.reject! { |d| d["matricula"].to_s == id_str }
  end
end

# Verifica consistência de matrículas.
#
# Argumentos:
#   - matricula (String): Aluno.
#   - codigo_turma (String): Turma.
#   - codigo_materia (String): Matéria.
def verify_enrollment_consistency(matricula, codigo_turma, codigo_materia)
  # 1. Busca os registros (Assignments)
  user = Usuario.find_by(matricula: matricula)
  turma = find_turma_by_full_code(codigo_turma, codigo_materia)

  # 2. Executa as validações (Conditionals/Calls)
  validate_enrollment_expectations(user, turma)
end

# --- Helpers de Busca ---

# Encontra turma por código completo.
#
# Retorno:
#   - (Turma): Turma encontrada.
def find_turma_by_full_code(codigo_turma, codigo_materia)
  # Usa joins para buscar a turma garantindo que pertence à matéria correta
  Turma.joins(:materia).find_by(
    codigo: codigo_turma, 
    materias: { codigo: codigo_materia }
  )
end

# --- Helpers de Asserção ---

# Valida expectativas de matrícula.
#
# Efeitos Colaterais:
#   - Realiza asserções RSpec.
def validate_enrollment_expectations(user, turma)
  expect(user).to be_present, "Usuário não encontrado."
  expect(turma).to be_present, "Turma não encontrada."
  
  # Verifica a associação
  expect(user.turmas).to include(turma)
end

# --- Orquestrador de Contexto ---

# Configura contexto SIGAA fake.
#
# Retorno:
#   - (Hash): Turma mockada.
def setup_sigaa_context
  codigo_materia = "CIC0097"
  codigo_turma = "TA"

  # Garante que a classe existe em @fake_classes
  ensure_class_exists(codigo_materia, codigo_turma)

  # Garante que a turma existe em @fake_members e retorna ela
  find_or_create_turma_member(codigo_materia, codigo_turma)
end

# --- Helpers de Infraestrutura ---

# Garante existência da classe no array fake.
#
# Efeitos Colaterais:
#   - Modifica @fake_classes.
def ensure_class_exists(code, class_code)
  return if @fake_classes.any? { |c| c["code"] == code }

  @fake_classes << {
    "name" => "Matéria Mock",
    "code" => code,
    "classCode" => class_code,
    "class" => {
      "classCode" => class_code,
      "semester" => "2024.1",
      "time" => "35T23"
    }
  }
end

# Encontra ou cria membro de turma.
#
# Retorno:
#   - (Hash): Turma membro.
def find_or_create_turma_member(code, class_code)
  turma = @fake_members.find { |m| m["code"] == code && m["classCode"] == class_code }
  return turma if turma

  new_turma = {
    "code" => code,
    "classCode" => class_code,
    "semester" => "2024.1",
    "dicente" => [],
    "docente" => mock_docente_data
  }
  @fake_members << new_turma
  new_turma
end

# Dados mock de docente.
#
# Retorno:
#   - (Hash): Dados docente.
def mock_docente_data
  {
    "nome" => "Prof Mock",
    "usuario" => "99999",
    "email" => "prof@mock.com",
    "ocupacao" => "docente"
  }
end

# --- Helper de Ação (Aluno) ---

# Insere ou atualiza aluno no sigaa fake.
#
# Argumentos:
#   - turma_mock (Hash): Turma.
#   - nome (String): Nome.
#   - matricula (String): Matrícula.
#   - email (String): Email.
def upsert_sigaa_student(turma_mock, nome, matricula, email)
  # Remove duplicatas baseadas na matrícula
  turma_mock["dicente"].reject! { |d| d["matricula"] == matricula }
  
  # Insere o novo dado
  turma_mock["dicente"] << {
    "nome" => nome,
    "matricula" => matricula,
    "usuario" => matricula,
    "email" => email,
    "ocupacao" => "dicente"
  }
end

# Verifica dados de criação do usuário.
#
# Argumentos:
#   - matricula (String): Matrícula.
#   - nome (String): Nome esperado.
#   - status_esperado (Boolean): Status esperado.
#
# Efeitos Colaterais:
#   - Realiza asserções.
def verify_user_creation_data(matricula, nome, status_esperado)
  user = Usuario.find_by(matricula: matricula)
  
  # Garante que o usuário existe antes de checar atributos
  expect(user).to be_present, "Usuário com matrícula #{matricula} não foi encontrado."
  
  # Checa os atributos
  expect(user.nome).to eq(nome)
  
  # Comparação direta de booleanos é mais robusta que user.status.to_s
  expect(user.status).to be(status_esperado)
end