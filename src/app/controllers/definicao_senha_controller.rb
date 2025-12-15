class DefinicaoSenhaController < ApplicationController
  skip_before_action :require_login, raise: false
  before_action :reset_session_before_start, only: [:new]
  before_action :resolve_user_from_token, only: %i[new create]

  layout "auth"

  def new
    if @usuario.status
      redirect_to login_path, notice: "Você já está ativo. Faça o login."
    end
  end

  def create
    return unless inputs_present?

    if @usuario.update(user_params.merge(status: true))
      redirect_to login_path, notice: "Senha definida com sucesso! Você já pode fazer o login."
    else
      handle_update_error
    end
  end

  private

  def user_params
    params.require(:usuario).permit(:password, :password_confirmation)
  end

  def reset_session_before_start
    return unless session[:usuario_id].present?

    session[:usuario_id] = nil
    flash[:notice] = "Sessão anterior encerrada para configurar nova conta."
  end

  def resolve_user_from_token
    token = params[:token]
    
    if token.blank?
      redirect_to login_path, alert: "Link inválido (token ausente)."
      return
    end

    @usuario = Usuario.find_signed(token, purpose: :definir_senha)

    return if @usuario

    redirect_to login_path, alert: "Link inválido ou expirado."
  end

  def inputs_present?
    p = user_params
    if p[:password].blank? || p[:password_confirmation].blank?
      flash.now[:alert] = "Todos os campos devem ser preenchidos."
      render :new, status: :unprocessable_content
      return false
    end
    true
  end

  def handle_update_error
    flash.now[:alert] = error_message_for_update
    render :new, status: :unprocessable_content
  end

  def error_message_for_update
    if @usuario.errors[:password_confirmation].present?
      "As senhas não conferem."
    else
      @usuario.errors.full_messages.to_sentence
    end
  end
end