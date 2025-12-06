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
        usuario: "999999", 
        password: "password123", 
        ocupacao: :docente, 
        status: true
      )

      classes_data.each do |cls|
        materia = Materia.find_or_create_by!(codigo: cls['code']) do |m|
          m.nome = cls['name']
        end

        Turma.find_or_create_by!(codigo: cls['code']) do |t|
          t.materia = materia
          t.docente = docente_padrao
          if cls['class']
            t.semestre = cls['class']['semester']
            t.horario  = cls['class']['time']
          end
          
          t.nome = cls['name'] if t.respond_to?(:nome=)
        end
      end

      members_data.each do |turma_data|
        turma = Turma.find_by(codigo: turma_data['code'])
        unless turma
          next 
        end

        if turma_data['docente']
          doc_data = turma_data['docente']
          docente_real = Usuario.find_or_create_by!(matricula: doc_data['usuario']) do |u|
            u.nome = doc_data['nome']
            u.email = doc_data['email']
            u.usuario = doc_data['usuario']
            u.password = "123456"
            u.ocupacao = :docente
            u.status = true
          end
          turma.update!(docente: docente_real)
        end

        if turma_data['dicente']
          turma_data['dicente'].each do |aluno_data|
            user = Usuario.find_or_create_by!(matricula: aluno_data['matricula']) do |u|
              u.nome = aluno_data['nome']
              u.email = aluno_data['email'] || "#{aluno_data['matricula']}@aluno.unb.br"
              u.usuario = aluno_data['usuario']
              u.password = "123456"
              u.ocupacao = :discente
              u.status = true
            end

            unless user.turmas.exists?(turma.id)
              user.turmas << turma
            end
          end
        end
      end
    end
  end
end