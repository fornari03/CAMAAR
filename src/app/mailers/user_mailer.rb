# Mailer responsável pelo envio de emails relacionados a usuários (senha, boas-vindas).
class UserMailer < ApplicationMailer
  default from: 'nao-responda@camaar.unb.br'

  # Envia email com link para definição da senha inicial.
  #
  # Argumentos:
  #   - params[:user] (Usuario): O usuário.
  #
  # Retorno:
  #   - (Mail::Message): Objeto de email para envio.
  #
  # Efeitos Colaterais:
  #   - Gera token assinado.
  def definicao_senha
    @user = params[:user]

    token = @user.signed_id(purpose: :definir_senha, expires_in: 24.hours)

    @url = definir_senha_url(token: token)

    mail(to: @user.email, subject: 'Definição de Senha - Sistema CAMAAR')
  end

  # Envia email com link para redefinição de senha esquecida.
  #
  # Argumentos:
  #   - params[:user] (Usuario): O usuário.
  #
  # Retorno:
  #   - (Mail::Message): Objeto de email para envio.
  #
  # Efeitos Colaterais:
  #   - Gera token assinado.
  def redefinicao_senha
    @user = params[:user]
    
    token = @user.signed_id(purpose: :redefinir_senha, expires_in: 15.minutes)
    
    @url = edit_redefinir_senha_url(token: token)

    mail(to: @user.email, subject: 'Redefinição de Senha - Sistema CAMAAR')
  end
end