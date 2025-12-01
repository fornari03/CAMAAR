require 'rails_helper'

RSpec.describe SigaaImporter do
  describe '.call' do
    # MOCK DATA
    let(:classes_json) do
      [
        {
          "name" => "BANCOS DE DADOS",
          "code" => "CIC0097",
          "semester" => "2024.1",
          "schedule" => "35T23"
        }
      ].to_json
    end

    let(:members_json) do
      [
        {
          "name" => "Fulano Teste",
          "registration" => "123456789",
          "class_code" => "CIC0097"
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
        expect(turma.docente).to eq(docente)
      end

      it 'cria o usuário aluno' do
        expect { described_class.call }.to change(Usuario, :count).by(1)
        aluno = Usuario.find_by(matricula: '123456789')
        expect(aluno.nome).to eq('Fulano Teste')
      end

      it 'matricula o aluno na turma' do
        described_class.call
        aluno = Usuario.find_by(matricula: '123456789')
        turma = Turma.find_by(codigo: 'CIC0097')
        
        expect(aluno.turmas).to include(turma)
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