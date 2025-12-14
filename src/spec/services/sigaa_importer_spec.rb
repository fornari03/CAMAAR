require 'rails_helper'

RSpec.describe SigaaImporter do
  describe '.call' do
    # MOCK DATA
    let(:classes_json) do
      [
        {
          "name" => "BANCOS DE DADOS",
          "code" => "CIC0097",
          "class" => {
            "classCode" => "TA",
            "semester" => "2024.1",
            "time" => "35T23"
          }
        }
      ].to_json
    end

    let(:members_json) do
      [
        {
          "code" => "CIC0097",
          "classCode" => "TA",
          "semester" => "2021.2",
          "dicente" => [
            {
              "nome" => "Fulano Teste",
              "matricula" => "123456789",
              "usuario" => "123456789",
              "email" => "fulano@teste.com",
              "ocupacao" => "dicente"
            }
          ],
          "docente" => {
              "nome" => "Prof. Real",
              "usuario" => "88888",
              "email" => "prof@real.com",
              "ocupacao" => "docente"
          }
        }
      ].to_json
    end

    let!(:docente) do
      Usuario.create!(
        nome: "Prof. Mock", email: "prof@mock.com", matricula: "0000", 
        usuario: "profmock", password: "123", ocupacao: :docente, status: true
      )
    end

    context 'quando os arquivos JSON existem e são válidos' do
      before do
        allow(File).to receive(:read).and_call_original
        
        allow(File).to receive(:read).with(satisfy { |path| path.to_s.include?('classes.json') })
          .and_return(classes_json)
          
        allow(File).to receive(:read).with(satisfy { |path| path.to_s.include?('class_members.json') })
          .and_return(members_json)
      end

      it 'cria a matéria correspondente' do
        expect { described_class.call }.to change(Materia, :count).by(1)
      end

      it 'cria a turma associada à matéria e ao docente' do
        expect { described_class.call }.to change(Turma, :count).by(1)
        turma = Turma.last
        expect(turma.codigo).to eq('TA')
        expect(turma.materia.codigo).to eq('CIC0097')
        expect(turma.docente.nome).to eq('Prof. Real') 
        expect(turma.docente.matricula).to eq('88888')
      end

      it 'cria os usuários aluno e professor presentes no JSON' do
        expect { described_class.call }.to change(Usuario, :count).by(2)
        
        described_class.call
        
        aluno = Usuario.find_by(matricula: '123456789')
        expect(aluno).to be_present
        expect(aluno.nome).to eq('Fulano Teste')
      end

      it 'matricula o aluno na turma' do
        described_class.call
        aluno = Usuario.find_by(matricula: '123456789')
        materia = Materia.find_by(codigo: 'CIC0097')
        turma = Turma.find_by(codigo: 'TA', materia: materia)
        
        expect(aluno.turmas).to include(turma)
      end
    end

    context 'quando os dados já existem mas mudaram no SIGAA' do
      let(:classes_json) do
        [
          {
            "name" => "BANCOS DE DADOS AVANÇADO",
            "code" => "CIC0097",
            "class" => {
              "classCode" => "TA",
              "semester" => "2024.1",
              "time" => "35T23"
            }
          }
        ].to_json
      end

      let(:members_json) do
        [
          {
            "code" => "CIC0097",
            "classCode" => "TA",
            "semester" => "2024.1",
            "dicente" => [
              {
                "nome" => "Fulano da Silva",
                "matricula" => "150084006",
                "usuario" => "150084006",
                "email" => "fulano.novo@gmail.com",
                "ocupacao" => "dicente"
              }
            ],
            "docente" => {
                "nome" => "Prof. Real",
                "usuario" => "88888",
                "email" => "prof@real.com",
                "ocupacao" => "docente"
            }
          }
        ].to_json
      end

      let!(:aluno_existente) do
        Usuario.create!(
          nome: "Fulano de Tal",
          matricula: "150084006",
          usuario: "150084006",
          email: "fulano.antigo@email.com",
          password: "123", ocupacao: :discente, status: true
        )
      end

      let!(:turma_existente) do
        m = Materia.create!(nome: "BANCOS DE DADOS", codigo: "CIC0097")
        
        Turma.create!(
          codigo: "TA",
          materia: m,
          docente: docente,
          semestre: "2024.1", horario: "35T23"
        )
      end

      let!(:aluno_removido) do
        Usuario.create!(
          nome: "Beltrano", 
          matricula: "150084008",
          usuario: "150084008", email: "beltrano@email.com", password: "123", ocupacao: :discente, status: true
        )
      end

      let!(:turma_removida) do
         m = Materia.create!(nome: "Materia Velha", codigo: "OLD0001")

         Turma.create!(
          codigo: "OLD0001",
          materia: m,
          docente: docente, semestre: "2024.1", horario: "35T23"
        )
      end

      before do
        allow(File).to receive(:read).with(satisfy { |p| p.to_s.include?('classes.json') }).and_return(classes_json)
        allow(File).to receive(:read).with(satisfy { |p| p.to_s.include?('class_members.json') }).and_return(members_json)
      end

      it 'atualiza o e-mail e nome do aluno' do
        described_class.call
        aluno_existente.reload
        
        expect(aluno_existente.email).to eq("fulano.novo@gmail.com")
        expect(aluno_existente.nome).to eq("Fulano da Silva")
      end

      it 'atualiza o nome da turma' do
        described_class.call
        turma_existente.reload
        
        expect(turma_existente.materia.reload.nome).to eq("BANCOS DE DADOS AVANÇADO")
      end

      it 'matricula o aluno na turma se ele não estava matriculado' do
        expect(aluno_existente.turmas).to be_empty
        
        described_class.call
        aluno_existente.reload
        
        expect(aluno_existente.turmas).to include(turma_existente)
      end

      it 'exclui alunos que não estão mais no arquivo' do
        described_class.call
        
        expect(Usuario.find_by(id: aluno_removido.id)).to be_nil
        expect(Usuario.find_by(id: aluno_existente.id)).to be_present
      end

      it 'exclui turmas que não estão mais no arquivo' do
        described_class.call
        
        expect(Turma.find_by(id: turma_removida.id)).to be_nil
        expect(Turma.find_by(id: turma_existente.id)).to be_present
      end
    end

    context 'funcionalidade de cadastro e convite por email' do
      before do
        ActionMailer::Base.deliveries.clear
        allow(File).to receive(:read).with(satisfy { |p| p.to_s.include?('classes.json') }).and_return(classes_json)
        allow(File).to receive(:read).with(satisfy { |p| p.to_s.include?('class_members.json') }).and_return(members_json_feature)
      end

      context 'quando importa um usuário novo com email' do
        let(:members_json_feature) do
          [
            {
              "code" => "CIC0097", "classCode" => "TA",
              "dicente" => [
                { "nome" => "Novo Aluno", "matricula" => "NEW100", "usuario" => "NEW100", "email" => "novo@email.com", "ocupacao" => "dicente" }
              ],
              "docente" => { "nome" => "Prof", "usuario" => "P99", "email" => "p@p.com", "ocupacao" => "docente" }
            }
          ].to_json
        end

        it 'cria o usuário e envia e-mail de definição de senha' do
          expect { described_class.call }.to change(Usuario, :count).by_at_least(1)
          
          user = Usuario.find_by(matricula: "NEW100")
          expect(user).to be_present
          expect(user.status).to be_falsey
          
          email = ActionMailer::Base.deliveries.find { |e| e.to.include?("novo@email.com") }
          expect(email).to be_present
          expect(email.subject).to include("Definição de Senha")
        end
      end

      context 'quando importa um usuário que já existe' do
        let!(:aluno_existente_feature) do
          Usuario.create!(
            nome: "Aluno Existe", matricula: "EXISTE100", usuario: "EXISTE100",
            email: "existe@email.com", password: "123", ocupacao: :discente, status: true
          )
        end

        let(:members_json_feature) do
          [
            {
              "code" => "CIC0097", "classCode" => "TA",
              "dicente" => [
                { "nome" => "Aluno Existe", "matricula" => "EXISTE100", "usuario" => "EXISTE100", "email" => "existe@email.com", "ocupacao" => "dicente" }
              ],
              "docente" => { "nome" => "Prof", "usuario" => "P99", "email" => "p@p.com", "ocupacao" => "docente" }
            }
          ].to_json
        end

        it 'não envia e-mail e não duplica o usuário' do
          expect { described_class.call }.not_to change { ActionMailer::Base.deliveries.count }
          expect(Usuario.where(matricula: "EXISTE100").count).to eq(1)
        end
      end

      context 'quando importa um usuário novo sem email' do
        let(:members_json_feature) do
          [
            {
              "code" => "CIC0097", "classCode" => "TA",
              "dicente" => [
                { "nome" => "Sem Email", "matricula" => "NOEMAIL100", "usuario" => "NOEMAIL100", "email" => nil, "ocupacao" => "dicente" }
              ],
              "docente" => { "nome" => "Prof", "usuario" => "P99", "email" => "p@p.com", "ocupacao" => "docente" }
            }
          ].to_json
        end

        it 'não cria o usuário no sistema' do
          expect { 
            described_class.call 
          }.to raise_error(StandardError, /e-mail ausente/)

          expect(Usuario.find_by(matricula: "NOEMAIL100")).to be_nil
        end
      end
    end

    context 'quando os arquivos não são encontrados' do
      before do
        allow(File).to receive(:read).and_raise(Errno::ENOENT)
      end

      it 'lança um erro tratável' do
        expect { described_class.call }.to raise_error(StandardError, /Não foi possível buscar os dados/)
      end
    end

    context 'Cenários de Erro e Cobertura de Borda' do
      before do
        allow(File).to receive(:read).with(satisfy { |p| p.to_s.include?('classes.json') }).and_return(classes_json)
        allow(File).to receive(:read).with(satisfy { |p| p.to_s.include?('class_members.json') }).and_return(members_json)
      end

      it 'recria a turma se ela não for encontrada durante o processamento de membros' do

        allow(Turma).to receive(:create!).and_call_original
        
        allow(Turma).to receive(:find_by).with(hash_including(codigo: "TA")).and_return(nil)

        expect(Turma).to receive(:create!).with(hash_including(codigo: "TA", semestre: "2024.1"))
        
        described_class.call
      end

      it 'registra erro no log quando o envio de e-mail falha' do
        new_members_json = [
          {
            "code" => "CIC0097", "classCode" => "TA",
            "dicente" => [{ "nome" => "Novo", "matricula" => "NEW", "usuario" => "NEW", "email" => "n@n.com", "ocupacao" => "dicente" }],
            "docente" => { "nome" => "P", "usuario" => "P", "email" => "p@p.com", "ocupacao" => "docente" }
          }
        ].to_json
        
        allow(File).to receive(:read).with(satisfy { |p| p.to_s.include?('class_members.json') }).and_return(new_members_json)
        
        allow(UserMailer).to receive(:with).and_raise(StandardError, "Erro SMTP Simulado")
        
        expect(Rails.logger).to receive(:error).with(/Falha ao enviar e-mail para.*Erro SMTP Simulado/)
        
        described_class.call
      end

      it 'inativa o usuário em vez de deletar se ocorrer erro de chave estrangeira' do
        usuario_para_remover = Usuario.create!(
          nome: "User Old", matricula: "OLD123", usuario: "OLD123",
          email: "old@email.com", password: "123", ocupacao: :discente, status: true
        )

        allow_any_instance_of(Usuario).to receive(:destroy).and_wrap_original do |method, *args|
          usuario_atual = method.receiver 
          
          if usuario_atual.id == usuario_para_remover.id
            raise ActiveRecord::InvalidForeignKey.new("Erro FK simulado")
          else
            method.call(*args)
          end
        end

        allow(Rails.logger).to receive(:info)

        described_class.call
        
        expect(Rails.logger).to have_received(:info).with(/Usuário OLD123 inativado/)
        
        expect(usuario_para_remover.reload.status).to be(false)
        expect(Usuario.exists?(usuario_para_remover.id)).to be(true)
      end
    end
  end
end