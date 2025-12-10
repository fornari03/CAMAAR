class RedefinicaoSenhaController < ApplicationController
  skip_before_action :require_login, raise: false
  layout "auth"

  # POST /esqueci_senha
  def create
    email = params[:email]

    if email.blank?
      redirect_to login_path, alert: "O campo de e-mail não pode estar vazio."
      return
    end

    user = Usuario.find_by(email: email)

    if user
      if user.status == false
        redirect_to login_path, alert: "Você ainda não definiu sua senha. Por favor, verifique seu e-mail para definir sua senha."
        return
      end
      UserMailer.with(user: user).redefinicao_senha.deliver_now
    end

    redirect_to login_path, notice: "Se este e-mail estiver cadastrado, um link de redefinição foi enviado."
  end

  # GET /redefinir_senha/edit
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