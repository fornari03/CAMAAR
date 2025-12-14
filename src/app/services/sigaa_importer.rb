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

        codigo_turma = cls['class']['classCode']

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
            semestre: classes_data.find { |c| c['code'] == turma_data['code'] }['class']['semester'],
            horario: classes_data.find { |c| c['code'] == turma_data['code'] }['class']['time'],
            docente: docente_padrao
          )
        end
        
        active_turma_ids << turma.id

        if turma_data['docente']
          doc_data = turma_data['docente']
          docente_real = Usuario.find_or_initialize_by(matricula: doc_data['usuario'].to_s)
          eh_novo_docente = docente_real.new_record?
          
          docente_real.assign_attributes(
            nome: doc_data['nome'],
            email: doc_data['email'],
            usuario: doc_data['usuario'],
            ocupacao: :docente
          )
          
          if eh_novo_docente
            docente_real.password = SecureRandom.hex(8) 
            docente_real.status = false
          end

          docente_real.save!
          active_user_ids << docente_real.id
          turma.update!(docente: docente_real)
        end

        if turma_data['dicente']
          turma_data['dicente'].each do |aluno_data|
            
            email_aluno = aluno_data['email']
            
            if email_aluno.nil? || email_aluno.to_s.strip.empty?
              raise StandardError, "Falha ao importar usuário '#{aluno_data['matricula']}': e-mail ausente."
            end

            next if email_aluno.nil? || email_aluno.to_s.strip.empty?

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
                Rails.logger.error "Falha ao enviar e-mail para #{user.email}: #{e.message}"
              end
            end

            unless user.turmas.exists?(turma.id)
              user.turmas << turma
            end
          end
        end
      end
      
      Turma.where.not(id: active_turma_ids).destroy_all

      users_to_remove = Usuario.where(ocupacao: [:discente, :docente]).where.not(id: active_user_ids)
      
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
end