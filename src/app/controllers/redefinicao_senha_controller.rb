# Controlador para fluxo de "Esqueci minha senha".
class RedefinicaoSenhaController < ApplicationController
  skip_before_action :require_login, raise: false
  before_action :resolve_user_from_token, only: %i[edit update]

  layout "auth"

  # Processa a solicitação de redefinição de senha (envio de email).
  #
  # Argumentos:
  #   - params[:email] (String): Email do usuário.
  #
  # Retorno:
  #   - (NilClass): Redireciona com aviso.
  #
  # Efeitos Colaterais:
  #   - Envia email de redefinição se usuário encontrado.
  def create
    return handle_missing_email if params[:email].blank?

    user = Usuario.find_by(email: params[:email])
    
    process_reset_request(user) if user

    redirect_to login_path, notice: "Se este e-mail estiver cadastrado, um link de redefinição foi enviado." unless performed?
  end

  # Renderiza o formulário de definição de nova senha.
  #
  # Argumentos:
  #   - params[:token] (String): Token de redefinição.
  #
  # Efeitos Colaterais:
  #   - Carrega @usuario via before_action.
  def edit
    # @usuario já carregado pelo before_action
  end

  # Atualiza a senha do usuário.
  #
  # Argumentos:
  #   - params[:usuario]: Campos de senha.
  #
  # Retorno:
  #   - (NilClass): Redireciona ou re-renderiza.
  #
  # Efeitos Colaterais:
  #   - Atualiza senha no DB.
  def update
    if @usuario.update(user_params)
      redirect_to login_path, notice: "Senha redefinida com sucesso! Você já pode fazer o login."
    else
      flash.now[:alert] = @usuario.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_content
    end
  end

  private

  # Sanitiza parâmetros.
  #
  # Retorno:
  #   - (ActionController::Parameters): Params permitidos.
  def user_params
    params.require(:usuario).permit(:password, :password_confirmation)
  end

  # Lida com email ausente na solicitação.
  #
  # Efeitos Colaterais:
  #   - Redireciona com erro.
  def handle_missing_email
    redirect_to login_path, alert: "O campo de e-mail não pode estar vazio."
  end

  # Envia o email de redefinição.
  #
  # Argumentos:
  #   - user (Usuario): O usuário.
  #
  # Efeitos Colaterais:
  #   - Envia email UserMailer.redefinicao_senha.
  def process_reset_request(user)
    if user.status == false
      redirect_to login_path, alert: "Você ainda não definiu sua senha. Por favor, verifique seu e-mail para definir sua senha."
    else
      UserMailer.with(user: user).redefinicao_senha.deliver_now
    end
  end

  # Resolve o usuário a partir do token.
  #
  # Argumentos:
  #   - params[:token]
  #
  # Efeitos Colaterais:
  #   - Define @usuario ou redireciona se inválido.
  def resolve_user_from_token
    @token = params[:token]
    @usuario = Usuario.find_signed(@token, purpose: :redefinir_senha)

    return if @usuario

    redirect_to login_path, alert: "Link inválido ou expirado."
  end
end