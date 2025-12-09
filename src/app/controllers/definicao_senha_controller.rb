class DefinicaoSenhaController < ApplicationController
  skip_before_action :require_login, raise: false
  
  before_action :reset_session_before_start, only: [:new]

  layout "auth"

  def new
    token = params[:token]
    
    if token.blank?
      redirect_to login_path, alert: "Link inválido (token ausente)."
      return
    end
    
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
      redirect_to login_path, alert: "Link inválido ou expirado."
      return
    end

    p = user_params
    if p[:password].blank? || p[:password_confirmation].blank?
      flash.now[:alert] = "Todos os campos devem ser preenchidos."
      render :new, status: :unprocessable_entity
      return
    end

    if @usuario.update(user_params.merge(status: true))
      # session[:usuario_id] = @usuario.id
      redirect_to login_path, notice: "Senha definida com sucesso! Você já pode fazer o login."
    else
      if @usuario.errors[:password_confirmation].present?
        flash.now[:alert] = "As senhas não conferem."
      else
        flash.now[:alert] = @usuario.errors.full_messages.to_sentence
      end
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:usuario).permit(:password, :password_confirmation)
  end

  def reset_session_before_start
    if session[:usuario_id].present?
      session[:usuario_id] = nil
      flash[:notice] = "Sessão anterior encerrada para configurar nova conta."
    end
  end
end