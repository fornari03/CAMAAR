require "rails_helper"

# Testes par UserMailer.
#
# Cobre o envio de emails de redefinição de senha.
RSpec.describe UserMailer, type: :mailer do
  # Teste de redefinição de senha.
  describe "redefinicao_senha" do
    let(:user) { 
      Usuario.create!(
        nome: "Teste Reset", 
        email: "reset@teste.com", 
        usuario: "111222", 
        matricula: "111222", 
        ocupacao: :discente, 
        status: true, 
        password: "OldPass123!", 
      ) 
    }
    
    let(:mail) { UserMailer.with(user: user).redefinicao_senha }

    it "renderiza os cabeçalhos corretamente" do
      expect(mail.subject).to eq("Redefinição de Senha - Sistema CAMAAR")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["nao-responda@camaar.unb.br"])
    end

    it "renderiza o corpo com a URL correta" do
      body = mail.body.encoded

      expect(body).to include("redefinir a senha")
      expect(body).to include("Redefinir minha senha")
      
      expect(body).to include("/redefinir_senha/edit")
      
      expect(body).to include("token=")
    end
  end
end