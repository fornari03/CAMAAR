class DefinicaoSenhaController < ApplicationController
  # permite acesso sem estar logado
  skip_before_action :require_login, raise: false 
  layout "auth"

  def new
    token = params[:token]
    
    @usuario = Usuario.find_signed(token, purpose: :definir_senha)

    if @usuario.nil?
      redirect_to login_path, alert: "Link inválido ou expirado."
    elsif @usuario.status == true
      redirect_to login_path, notice: "Você já está ativo. Faça o login."
    end
  end

  def create
    token = params[:token]
    @usuario = Usuario.find_signed(token, purpose: :definir_senha)

    if @usuario.nil?
      redirect_to login_path, alert: "Link inválido."
      return
    end

    if @usuario.update(user_params.merge(status: true))
      redirect_to login_path, notice: "Senha definida com sucesso! Você já pode fazer o login."
    else
      flash.now[:alert] = @usuario.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:usuario).permit(:password, :password_confirmation)
  end
end