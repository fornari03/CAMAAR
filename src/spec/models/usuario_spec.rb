require 'rails_helper'

# Testes de modelo para Usuario.
#
# Cobre autenticação, validação de senha, roles e escopos de pendência.
RSpec.describe Usuario, type: :model do
  let(:usuario_ativo) { 
    Usuario.create!(
      nome: 'User Ativo', email: 'ativo@test.com', usuario: 'ativo', 
      matricula: '111', password: 'password', ocupacao: :discente, status: true
    ) 
  }

  let(:usuario_pendente) { 
    Usuario.create!(
      nome: 'User Pendente', email: 'pendente@test.com', usuario: 'pendente', 
      matricula: '222', password: 'password', ocupacao: :discente, status: false
    ) 
  }

  let(:admin) { 
    Usuario.create!(
      nome: 'Admin', email: 'admin@test.com', usuario: 'admin', 
      matricula: '999', password: 'password', ocupacao: :admin, status: true
    ) 
  }

  describe 'associations' do
    it 'has many respostas' do
      expect(Usuario.reflect_on_association(:respostas).macro).to eq :has_many
    end
  end

  describe 'attributes' do
    it "persists attributes correctly" do
      expect(usuario_ativo).to be_persisted
      expect(usuario_ativo.status).to be true
    end
  end

  # Teste de verificação de role admin.
  describe '#admin?' do
    it 'retorna true se ocupacao for admin' do
      expect(admin.admin?).to be true
    end

    it 'retorna false se ocupacao não for admin' do
      expect(usuario_ativo.admin?).to be false
    end
  end

  # Teste de autenticação customizada.
  describe '.authenticate' do
    context 'Caminho Feliz' do
      it 'retorna o usuário se as credenciais estiverem corretas' do
        expect(Usuario.authenticate(usuario_ativo.email, 'password')).to eq(usuario_ativo)
        expect(Usuario.authenticate(usuario_ativo.usuario, 'password')).to eq(usuario_ativo)
        expect(Usuario.authenticate(usuario_ativo.matricula, 'password')).to eq(usuario_ativo)
      end
    end

    context 'Erros de Autenticação' do
      it 'lança erro se o usuário não for encontrado' do
        expect {
          Usuario.authenticate('nao_existe@test.com', 'password')
        }.to raise_error(AuthenticationError, "Usuário não encontrado")
      end

      it 'lança erro se o usuário estiver pendente (status false)' do
        expect {
          Usuario.authenticate(usuario_pendente.email, 'password')
        }.to raise_error(AuthenticationError, /Sua conta está pendente/)
      end

      it 'lança erro se a senha estiver incorreta' do
        expect {
          Usuario.authenticate(usuario_ativo.email, 'senha_errada')
        }.to raise_error(AuthenticationError, "Senha incorreta")
      end
    end
  end

  # Teste de validação de senha atual.
  describe '#validate_current_password' do
    
    it 'adiciona erro se current_password estiver incorreto' do
      usuario_ativo.current_password = 'senha_errada_teste'
      usuario_ativo.validate
      
      expect(usuario_ativo.errors[:current_password]).to include("está incorreta")
    end

    it 'não valida se current_password estiver em branco' do
      usuario_ativo.current_password = ''
      usuario_ativo.validate
      
      expect(usuario_ativo.errors[:current_password]).to be_empty
    end

    it 'passa se current_password estiver correto' do
      usuario_ativo.current_password = 'password'
      usuario_ativo.validate
      
      expect(usuario_ativo.errors[:current_password]).to be_empty
    end
  end

  # Teste de recuperação de pendências.
  describe '#pendencias' do
    let(:template) { Template.create!(name: 'T1', id_criador: usuario_ativo.id, titulo: 'T', participantes: 'todos') }
    let(:materia) { Materia.create!(codigo: 'M', nome: 'N') }
    let(:turma) { Turma.create!(codigo: 'X', semestre: '2024', horario: '2M', materia: materia, docente: usuario_ativo) }
    let(:formulario) { Formulario.create!(template: template, turma: turma, titulo_envio: 'Envio 1', data_criacao: Time.now) }
    
    it 'returns only unanswered responses' do
      formulario2 = Formulario.create!(template: template, turma: turma, titulo_envio: 'Envio 2', data_criacao: Time.now)
      r1 = Resposta.create!(participante: usuario_ativo, formulario: formulario)
      r2 = Resposta.create!(participante: usuario_ativo, formulario: formulario2, data_submissao: Time.now)

      expect(usuario_ativo.pendencias).to include(r1)
      expect(usuario_ativo.pendencias).not_to include(r2)
    end
  end
end