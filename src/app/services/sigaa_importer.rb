require 'json'
require 'securerandom'

# Serviço responsável pela importação e sincronização de dados do SIGAA.
# Lê arquivos JSON (classes.json e class_members.json) e atualiza Matérias, Turmas e Usuários.
class SigaaImporter
  # Método de classe utilitário para instanciar e executar o importador.
  #
  # Argumentos:
  #   - Nenhum
  #
  # Retorno:
  #   - (Any): O retorno do método call de instância.
  #
  # Efeitos Colaterais:
  #   - Veja o método call.
  def self.call
    new.call
  end

  # Inicializa o importador lendo os arquivos JSON de dados.
  #
  # Argumentos:
  #   - Nenhum
  #
  # Retorno:
  #   - (SigaaImporter): Uma nova instância.
  #
  # Efeitos Colaterais:
  #   - Lê arquivos do sistema de arquivos.
  #   - Pode levantar erro se os arquivos não existirem.
  def initialize
    classes_path = Rails.root.join('..', 'classes.json')
    members_path = Rails.root.join('..', 'class_members.json')

    begin
      @classes_data = JSON.parse(File.read(classes_path))
      @members_data = JSON.parse(File.read(members_path))
    rescue Errno::ENOENT
      raise StandardError, "Não foi possível buscar os dados. Tente novamente mais tarde."
    end

    @active_turma_ids = []
    @active_user_ids = []
  end

  # Executa o processo de importação completo.
  #
  # Argumentos:
  #   - Nenhum
  #
  # Retorno:
  #   - (NilClass): Retorna nil após a conclusão.
  #
  # Efeitos Colaterais:
  #   - Cria/Atualiza/Deleta registros de Usuários, Turmas e Matérias.
  #   - Abre transação no banco de dados.
  def call
    ActiveRecord::Base.transaction do
      setup_default_teacher
      process_definitions
      process_enrollments
      cleanup_data
    end
  end

  private

  # Cria ou recupera um docente padrão para turmas sem professor definido.
  #
  # Argumentos:
  #   - Nenhum
  #
  # Retorno:
  #   - (Usuario): O objeto do docente padrão.
  #
  # Efeitos Colaterais:
  #   - Cria um usuário docente se não existir.
  def setup_default_teacher
    @docente_padrao = Usuario.find_or_create_by!(matricula: "999999") do |u|
      u.nome = "Docente Importador"
      u.email = "docente@sistema.com"
      u.usuario = "999999"
      u.password = "password123"
      u.ocupacao = :docente
      u.status = true
    end
    @active_user_ids << @docente_padrao.id
  end

  # Processa as definições de turmas e matérias do arquivo classes.json.
  #
  # Argumentos:
  #   - Nenhum
  #
  # Retorno:
  #   - (Array): Lista de turmas processadas.
  #
  # Efeitos Colaterais:
  #   - Persiste Matérias e Turmas.
  def process_definitions
    @classes_data.each do |cls|
      materia = persist_materia(cls)
      persist_turma(cls, materia)
    end
  end

  # Persiste uma matéria no banco de dados.
  #
  # Argumentos:
  #   - cls (Hash): Dados da classe contendo código e nome da disciplina.
  #
  # Retorno:
  #   - (Materia): O objeto matéria persistido.
  #
  # Efeitos Colaterais:
  #   - Cria ou atualiza registro na tabela materias.
  def persist_materia(cls)
    materia = Materia.find_or_initialize_by(codigo: cls['code'])
    materia.nome = cls['name']
    materia.save!
    materia
  end

  # Persiste uma turma no banco de dados.
  #
  # Argumentos:
  #   - cls (Hash): Dados da classe/turma.
  #   - materia (Materia): Objeto da matéria associada.
  #
  # Retorno:
  #   - (Turma): O objeto turma persistido.
  #
  # Efeitos Colaterais:
  #   - Cria ou atualiza registro na tabela turmas.
  #   - Adiciona ID da turma à lista de turmas ativas.
  def persist_turma(cls, materia)
    class_info = cls['class']
    codigo_turma = class_info['classCode']

    turma = Turma.find_or_initialize_by(codigo: codigo_turma, materia: materia)
    
    turma.docente ||= @docente_padrao
    
    if class_info
      turma.semestre = class_info['semester']
      turma.horario  = class_info['time']
    end
    
    turma.save!
    @active_turma_ids << turma.id
  end

  # Processa as matrículas e associações de docentes do arquivo class_members.json.
  #
  # Argumentos:
  #   - Nenhum
  #
  # Retorno:
  #   - (Array): Resultado da iteração sobre os dados.
  #
  # Efeitos Colaterais:
  #   - Cria/Atualiza usuários (docentes e discentes).
  #   - Cria matrículas.
  def process_enrollments
    @members_data.each do |turma_data|
      materia = Materia.find_by(codigo: turma_data['code'])
      next unless materia

      turma = ensure_turma_fallback(turma_data, materia)
      @active_turma_ids << turma.id

      if turma_data['docente']
        process_teacher(turma, turma_data['docente'])
      end

      if turma_data['dicente']
        process_students_list(turma, turma_data['dicente'])
      end
    end
  end

  # Garante que a turma exista, criando-a se necessário (fallback).
  #
  # Argumentos:
  #   - turma_data (Hash): Dados da turma vindo dos membros.
  #   - materia (Materia): Matéria associada.
  #
  # Retorno:
  #   - (Turma): A turma encontrada ou criada.
  #
  # Efeitos Colaterais:
  #   - Pode criar uma nova turma se não existir.
  def ensure_turma_fallback(turma_data, materia)
    codigo = turma_data['classCode']
    turma = Turma.find_by(codigo: codigo, materia: materia)
    return turma if turma

    original_cls = @classes_data.find { |c| c['code'] == turma_data['code'] }['class']
    
    Turma.create!(
      codigo: codigo,
      materia: materia,
      semestre: original_cls['semester'],
      horario: original_cls['time'],
      docente: @docente_padrao
    )
  end

  # Atualiza o professor de uma turma.
  #
  # Argumentos:
  #   - turma (Turma): A turma a ser atualizada.
  #   - doc_data (Hash): Dados do docente.
  #
  # Retorno:
  #   - (Boolean): Resultado do update.
  #
  # Efeitos Colaterais:
  #   - Cria/Atualiza usuário docente.
  #   - Atualiza a associação da turma.
  def process_teacher(turma, doc_data)
    docente, _ = persist_user_common(doc_data['usuario'], doc_data, :docente)
    turma.update!(docente: docente)
  end

  # Processa a lista de estudantes de uma turma.
  #
  # Argumentos:
  #   - turma (Turma): A turma alvo.
  #   - students_list (Array): Lista de dados dos estudantes.
  #
  # Retorno:
  #   - (Array): Resultado da iteração.
  #
  # Efeitos Colaterais:
  #   - Chama import_single_student para cada aluno.
  def process_students_list(turma, students_list)
    students_list.each do |student_data|
      import_single_student(turma, student_data)
    end
  end

  # Importa um único estudante e o matricula na turma.
  #
  # Argumentos:
  #   - turma (Turma): A turma.
  #   - data (Hash): Dados do estudante.
  #
  # Retorno:
  #   - (Matricula/Array): A associação de turma ou nil.
  #
  # Efeitos Colaterais:
  #   - Cria/Atualiza usuário.
  #   - Envia email de boas-vindas se for novo.
  #   - Cria matrícula.
  def import_single_student(turma, data)
    validate_email!(data)

    user, is_new = persist_user_common(data['matricula'], data, :discente)

    if is_new
      send_welcome_email(user)
    end

    user.turmas << turma unless user.turmas.exists?(turma.id)
  end

  # Valida se o email está presente nos dados.
  #
  # Argumentos:
  #   - data (Hash): Dados do usuário.
  #
  # Retorno:
  #   - (NilClass): Se válido.
  #
  # Efeitos Colaterais:
  #   - Levanta erro (StandardError) se email ausente.
  def validate_email!(data)
    email = data['email'].to_s.strip
    if email.empty?
      raise StandardError, "Falha ao importar usuário '#{data['matricula']}': e-mail ausente."
    end
  end

  # Envia email de definição de senha para o usuário.
  #
  # Argumentos:
  #   - user (Usuario): O usuário destinatário.
  #
  # Retorno:
  #   - (Any): Resultado do deliver_now ou nil em erro.
  #
  # Efeitos Colaterais:
  #   - Envia email.
  #   - Loga erro se falhar.
  def send_welcome_email(user)
    UserMailer.with(user: user).definicao_senha.deliver_now
  rescue => e
    Rails.logger.error "Falha ao enviar e-mail para #{user.email}: #{e.message}"
  end

  # Lógica comum para persistir usuários (docentes ou discentes).
  #
  # Argumentos:
  #   - identifier (String): Matrícula ou identificador único.
  #   - data (Hash): Dados do usuário.
  #   - role (Symbol): Ocupação (:docente ou :discente).
  #
  # Retorno:
  #   - (Array): [user, is_new] - Objeto usuário e booleano indicando se é novo.
  #
  # Efeitos Colaterais:
  #   - Cria ou atualiza o usuário.
  #   - Define senha aleatória e status false para novos.
  def persist_user_common(identifier, data, role)
    user = Usuario.find_or_initialize_by(matricula: identifier.to_s)
    is_new = user.new_record?

    user.assign_attributes(
      nome: data['nome'],
      email: data['email'],
      usuario: data['usuario'],
      ocupacao: role
    )

    if is_new
      user.password = SecureRandom.hex(8)
      user.status = false
    end

    user.save!
    @active_user_ids << user.id

    [user, is_new]
  end

  # Remove dados obsoletos que não vieram na importação atual.
  #
  # Argumentos:
  #   - Nenhum
  #
  # Retorno:
  #   - (Any): Resultado das operações de limpeza.
  #
  # Efeitos Colaterais:
  #   - Remove turmas não ativas.
  #   - Remove ou inativa usuários não ativos.
  def cleanup_data
    Turma.where.not(id: @active_turma_ids).destroy_all

    users_to_remove = Usuario.where(ocupacao: [:discente, :docente]).where.not(id: @active_user_ids)
    
    users_to_remove.find_each do |user|
      begin
        user.destroy
      rescue ActiveRecord::InvalidForeignKey, ActiveRecord::StatementInvalid => e
        user.update_column(:status, false)
        Rails.logger.info "Usuário #{user.matricula} inativado."
      end
    end
  end
end