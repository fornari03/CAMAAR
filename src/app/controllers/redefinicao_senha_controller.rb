class RedefinicaoSenhaController < ApplicationController
  skip_before_action :require_login, raise: false
  before_action :resolve_user_from_token, only: %i[edit update]

  layout "auth"

  # POST /esqueci_senha
  def create
    return handle_missing_email if params[:email].blank?

    user = Usuario.find_by(email: params[:email])
    
    process_reset_request(user) if user

    redirect_to login_path, notice: "Se este e-mail estiver cadastrado, um link de redefinição foi enviado." unless performed?
  end

  # GET /redefinir_senha/edit
  def edit
    # @usuario já carregado pelo before_action
  end

  # PATCH /redefinir_senha
  def update
    if @usuario.update(user_params)
      redirect_to login_path, notice: "Senha redefinida com sucesso! Você já pode fazer o login."
    else
      flash.now[:alert] = @usuario.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_content
    end
  end

  private

  def user_params
    params.require(:usuario).permit(:password, :password_confirmation)
  end

  def handle_missing_email
    redirect_to login_path, alert: "O campo de e-mail não pode estar vazio."
  end

  def process_reset_request(user)
    if user.status == false
      redirect_to login_path, alert: "Você ainda não definiu sua senha. Por favor, verifique seu e-mail para definir sua senha."
    else
      UserMailer.with(user: user).redefinicao_senha.deliver_now
    end
  end

  def resolve_user_from_token
    @token = params[:token]
    @usuario = Usuario.find_signed(@token, purpose: :redefinir_senha)

    return if @usuario

    redirect_to login_path, alert: "Link inválido ou expirado."
  end
end