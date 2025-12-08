class UserMailer < ApplicationMailer
  default from: 'nao-responda@camaar.unb.br'

  def definicao_senha
    @user = params[:user]
    
    @url = "http://localhost:3000/definir_senha?email=#{@user.email}"

    mail(to: @user.email, subject: 'Definição de Senha - Sistema CAMAAR')
  end
end