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
        expect(turma.codigo).to eq('CIC0097')
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
        turma = Turma.find_by(codigo: 'CIC0097')
        
        expect(aluno.turmas).to include(turma)
      end
    end

    context 'quando os dados já existem mas mudaram no SIGAA' do
      let(:classes_json) do
        [
          {
            "name" => "BANCOS DE DADOS AVANÇADO",
            "code" => "CIC0097",
            "class" => { "semester" => "2024.1", "time" => "35T23" }
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
              "nome" => "Prof. Real", "usuario" => "88888", "email" => "prof@real.com", "ocupacao" => "docente"
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
        t = Turma.create!(
          nome: "BANCOS DE DADOS",
          codigo: "CIC0097",
          docente: docente,
          semestre: "2024.1", horario: "35T23", status: true
        )
        t.materia = Materia.create!(nome: "BD", codigo: "CIC0097")
        t.save!
        t
      end

      let!(:aluno_removido) do
        Usuario.create!(
          nome: "Beltrano", 
          matricula: "150084008",
          usuario: "150084008", email: "beltrano@email.com", password: "123", ocupacao: :discente, status: true
        )
      end

      let!(:turma_removida) do
         t = Turma.create!(
          nome: "TURMA VELHA", 
          codigo: "OLD0001",
          docente: docente, semestre: "2024.1", horario: "35T23", status: true
        )
        t.materia = Materia.create!(nome: "Velha", codigo: "OLD0001")
        t.save!
        t
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
        
        expect(turma_existente.nome).to eq("BANCOS DE DADOS AVANÇADO")
      end

      it 'matricula o aluno na turma se ele não estava matriculado' do
        expect(aluno_existente.turmas).to be_empty
        
        described_class.call
        aluno_existente.reload
        
        expect(aluno_existente.turmas).to include(turma_existente)
      end

      it 'desativa alunos que não estão mais no arquivo' do
        described_class.call
        aluno_removido.reload
        
        expect(aluno_removido.status).to be(false)
        expect(aluno_existente.reload.status).to be(true)
      end

      it 'desativa turmas que não estão mais no arquivo' do
        described_class.call
        turma_removida.reload
        
        expect(turma_removida.status).to be(false)
        expect(turma_existente.reload.status).to be(true)
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
  end
end