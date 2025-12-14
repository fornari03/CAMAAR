require 'json'
require 'securerandom'

class SigaaImporter
  def self.call
    new.call
  end

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

  def call
    ActiveRecord::Base.transaction do
      setup_default_teacher
      process_definitions
      process_enrollments
      cleanup_data
    end
  end

  private

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

  def process_definitions
    @classes_data.each do |cls|
      materia = persist_materia(cls)
      persist_turma(cls, materia)
    end
  end

  def persist_materia(cls)
    materia = Materia.find_or_initialize_by(codigo: cls['code'])
    materia.nome = cls['name']
    materia.save!
    materia
  end

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

  def process_teacher(turma, doc_data)
    docente, _ = persist_user_common(doc_data['usuario'], doc_data, :docente)
    turma.update!(docente: docente)
  end

  def process_students_list(turma, students_list)
    students_list.each do |student_data|
      import_single_student(turma, student_data)
    end
  end

  def import_single_student(turma, data)
    validate_email!(data)

    user, is_new = persist_user_common(data['matricula'], data, :discente)

    if is_new
      send_welcome_email(user)
    end

    user.turmas << turma unless user.turmas.exists?(turma.id)
  end

  def validate_email!(data)
    email = data['email'].to_s.strip
    if email.empty?
      raise StandardError, "Falha ao importar usuário '#{data['matricula']}': e-mail ausente."
    end
  end

  def send_welcome_email(user)
    UserMailer.with(user: user).definicao_senha.deliver_now
  rescue => e
    Rails.logger.error "Falha ao enviar e-mail para #{user.email}: #{e.message}"
  end

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