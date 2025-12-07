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
      active_turma_ids = []
      active_user_ids = []

      docente_padrao = Usuario.find_or_create_by!(matricula: "999999") do |u|
        u.nome = "Docente Importador"
        u.email = "docente@sistema.com"
        u.usuario = "999999"
        u.password = "password123"
        u.ocupacao = :docente
        u.status = true
      end
      active_user_ids << docente_padrao.id

      puts "AAAAAAAAAAAAAAA #{classes_data.inspect}"
      puts "BBBBBBBBBBBBBBB #{members_data.inspect}"
      classes_data.each do |cls|
        materia = Materia.find_or_initialize_by(codigo: cls['code'])
        materia.nome = cls['name']
        materia.save!

        codigo_turma = cls['class']['classCode']

        turma = Turma.find_or_create_by(codigo: codigo_turma, materia: materia)
        
        turma.docente = docente_padrao unless turma.docente
        
        if cls['class']
          turma.semestre = cls['class']['semester']
          turma.horario  = cls['class']['time']
        end
        
        turma.save!
        
        active_turma_ids << turma.id
      end

      members_data.each do |turma_data|
        materia = Materia.find_by(codigo: turma_data['code'])
        
        next unless materia

        codigo_turma = turma_data['classCode']
        turma = Turma.find_by(codigo: codigo_turma, materia: materia)
        puts "CCCCCCCCCCCCCCC #{turma.inspect}"
        puts "DDDDDDDDDDDDDDD #{materia.inspect}"

        next unless turma

        if turma_data['docente']
          doc_data = turma_data['docente']
          docente_real = Usuario.find_or_initialize_by(matricula: doc_data['usuario'].to_s)
          docente_real.assign_attributes(
            nome: doc_data['nome'],
            email: doc_data['email'],
            usuario: doc_data['usuario'],
            password: "123456",
            ocupacao: :docente,
            status: true
          )
          begin
            docente_real.save!
            active_user_ids << docente_real.id
            turma.update!(docente: docente_real)
          rescue ActiveRecord::RecordInvalid => e
            puts "\n🛑 ERRO AO SALVAR DOCENTE: #{doc_data['nome']}"
            puts "   MENSAGEM: #{e.message}"
            puts "   ERROS: #{docente_real.errors.full_messages}"
            puts "   DADOS TENTADOS: #{docente_real.attributes.inspect}\n"
            raise e # Lança o erro de novo para o teste falhar, mas agora você leu o motivo
          end
        end

        if turma_data['dicente']
          turma_data['dicente'].each do |aluno_data|
            user = Usuario.find_or_initialize_by(matricula: aluno_data['matricula'].to_s)
            
            user.assign_attributes(
              nome: aluno_data['nome'],
              email: aluno_data['email'] || "#{aluno_data['matricula']}@aluno.unb.br",
              usuario: aluno_data['usuario'],
              password: "123456",
              ocupacao: :discente,
              status: true
            )
            user.save!
            active_user_ids << user.id

            unless user.turmas.exists?(turma.id)
              user.turmas << turma
            end
          end
        end
      end

      Turma.where.not(id: active_turma_ids).destroy_all
      Usuario.where(ocupacao: [:discente, :docente]).where.not(id: active_user_ids).destroy_all
    end
  end
end