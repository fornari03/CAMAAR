require 'json'

class SigaaImporter
  def self.call
    classes_path = Rails.root.join('..', 'classes.json')
    members_path = Rails.root.join('..', 'class_members.json')

    begin
      classes_data = JSON.parse(File.read(classes_path))
      members_data = JSON.parse(File.read(members_path))
    rescue Errno::ENOENT
      raise StandardError, "Não foi possível buscar os dados. Tente novamente mais tarde."
    end

    ActiveRecord::Base.transaction do
      docente_padrao = Usuario.find_by(ocupacao: :docente) || Usuario.create!(
        nome: "Docente Importador", 
        email: "docente@sistema.com", 
        matricula: "999999", 
        usuario: "docente_imp", 
        password: "password123", 
        ocupacao: :docente, 
        status: true
      )

      classes_data.each do |cls|
        materia = Materia.find_or_create_by(codigo: cls['code']) do |m|
          m.nome = cls['name']
        end

        Turma.find_or_create_by(codigo: cls['code']) do |t|
          t.materia = materia
          t.docente = docente_padrao
          t.semestre = cls['semester']
          t.horario = cls['schedule']
          t.nome = cls['name'] if t.respond_to?(:nome=)
        end
      end

      members_data.each do |member|
        aluno = Usuario.find_or_create_by(matricula: member['registration']) do |u|
          u.nome = member['name']
          u.email = "#{member['registration']}@aluno.unb.br"
          u.usuario = member['registration']
          u.password = "123456"
          u.ocupacao = :discente
          u.status = true
        end

        turma = Turma.find_by(codigo: member['class_code'])
        
        if turma && aluno
          unless aluno.turmas.exists?(turma.id)
            aluno.turmas << turma
          end
        end
      end
    end
  end
end