require 'json'
require 'securerandom'

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

      classes_data.each do |cls|
        materia = Materia.find_or_initialize_by(codigo: cls['code'])
        materia.nome = cls['name']
        materia.save!

        codigo_turma = cls['class']['classCode'] || "#{cls['code']}"

        turma = Turma.find_or_initialize_by(codigo: codigo_turma, materia: materia)
        
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

        # se a turma não existir, cria agora para garantir integridade
        if !turma
          turma = Turma.create!(
            codigo: codigo_turma,
            materia: materia,
            semestre: turma_data['semester'],
            horario: classes_data.find { |c| c['code'] == turma_data['code'] }['class']['time'],
            docente: docente_padrao
          )
          active_turma_ids << turma.id
        end
        
        active_turma_ids << turma.id

        if turma_data['docente']
          doc_data = turma_data['docente']
          docente_real = Usuario.find_or_initialize_by(matricula: doc_data['usuario'].to_s)
          docente_real.assign_attributes(
            nome: doc_data['nome'],
            email: doc_data['email'],
            usuario: doc_data['usuario'],
            ocupacao: :docente,
            status: true
          )
          docente_real.password = "password123" if docente_real.new_record?

          docente_real.save!
          active_user_ids << docente_real.id
          turma.update!(docente: docente_real)
        end

        if turma_data['dicente']
          turma_data['dicente'].each do |aluno_data|
            
            # se não tem e-mail, não cria e nem processa
            email_aluno = aluno_data['email']
            if email_aluno.nil? || email_aluno.strip.empty?
              next 
            end

            user = Usuario.find_or_initialize_by(matricula: aluno_data['matricula'].to_s)
            eh_novo_usuario = user.new_record?

            user.assign_attributes(
              nome: aluno_data['nome'],
              email: email_aluno,
              usuario: aluno_data['usuario'],
              ocupacao: :discente
            )

            if eh_novo_usuario
              user.password = SecureRandom.hex(8) 
              user.status = false 
            end

            user.save!
            active_user_ids << user.id

            if eh_novo_usuario
              begin
                UserMailer.with(user: user).definicao_senha.deliver_now
              rescue => e
                Rails.logger.error "Falha ao importar usuário #{user.matricula}: #{e.message}"
              end
            end

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