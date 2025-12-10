class UserMailer < ApplicationMailer
  default from: 'nao-responda@camaar.unb.br'

  def definicao_senha
    @user = params[:user]

    token = @user.signed_id(purpose: :definir_senha, expires_in: 24.hours)

    @url = definir_senha_url(token: token)

    mail(to: @user.email, subject: 'Definição de Senha - Sistema CAMAAR')
  end

  def redefinicao_senha
    @user = params[:user]
    
    token = @user.signed_id(purpose: :redefinir_senha, expires_in: 15.minutes)
    
    @url = edit_redefinir_senha_url(token: token)

    mail(to: @user.email, subject: 'Redefinição de Senha - Sistema CAMAAR')
  end
end