class RedefinicaoSenhaController < ApplicationController
  skip_before_action :require_login, raise: false
  layout "auth"

  # GET /esqueci_senha
  def new
    # Renderiza o formulário de email
  end

  # POST /esqueci_senha
  def create
    email = params[:email]

    if email.blank?
      flash.now[:alert] = "O campo de e-mail não pode estar vazio."
      render :new, status: :unprocessable_entity
      return
    end

    user = Usuario.find_by(email: email)

    if user
      UserMailer.with(user: user).redefinicao_senha.deliver_later
    end

    redirect_to login_path, notice: "Se este e-mail estiver cadastrado, um link de redefinição foi enviado."
  end

  # GET /redefinir_senha/edit?token=...
  def edit
    @token = params[:token]
    @usuario = Usuario.find_signed(@token, purpose: :redefinir_senha)

    if @usuario.nil?
      redirect_to login_path, alert: "Link inválido ou expirado."
    end
  end

  # PATCH /redefinir_senha
  def update
    @token = params[:token]
    @usuario = Usuario.find_signed(@token, purpose: :redefinir_senha)

    if @usuario.nil?
      redirect_to login_path, alert: "Link inválido ou expirado."
      return
    end

    if @usuario.update(user_params)
      redirect_to login_path, notice: "Senha redefinida com sucesso! Você já pode fazer o login."
    else
      flash.now[:alert] = @usuario.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:usuario).permit(:password, :password_confirmation)
  end
end