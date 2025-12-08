class PasswordController < ApplicationController
  # GET /password/forgot
  # Mostra o formulário "esqueci minha senha"
  def new_forgot
    # renderiza app/views/password/new_forgot.html.erb
  end

  # POST /password/forgot
  # Envia o email de redefinição de senha (se o usuário existir)
  def forgot
    email = params[:email]

    if email.blank?
      flash.now[:alert] = "Você precisa informar um e-mail."
      return render :new_forgot, status: :unprocessable_entity
    end
    
    usuario = Usuario.find_by(email: email)

    if usuario
      result = EmailService.send_password_reset_email(usuario)

      if result[:success]
        redirect_to login_path, notice: "Enviamos um email com instruções para redefinir sua senha."
      else
        flash.now[:alert] = "Ocorreu um erro ao enviar o email. Tente novamente mais tarde."
        render :new_forgot, status: :internal_server_error
      end
    else
      # Mesma mensagem para não revelar se o email existe ou não
      redirect_to login_path, notice: "Se o email estiver cadastrado, você receberá instruções para redefinir sua senha."
    end
  end

  # GET /password/reset
  # Mostra o formulário de redefinição de senha
  def new_reset
    @usuario_email = params[:email]
    # renderiza app/views/password/new_reset.html.erb
  end

  # POST /password/reset
  # Redefine a senha do usuário (sem validação por token)
  def reset
    email = params[:email]
    password = params[:password]
    password_confirmation = params[:password_confirmation]

    Rails.logger.debug "DEBUG Reset - email: #{email}, password: #{password ? '[PRESENT]' : '[MISSING]'}, password_confirmation: #{password_confirmation ? '[PRESENT]' : '[MISSING]'}"

    if [email, password, password_confirmation].any?(&:blank?)
      flash.now[:alert] = "Todos os campos são obrigatórios."
      @usuario_email = email
      return render :new_reset, status: :unprocessable_entity
    end

    unless password == password_confirmation
      flash.now[:alert] = "As senhas não coincidem."
      @usuario_email = email
      return render :new_reset, status: :unprocessable_entity
    end

    usuario = Usuario.find_by(email: email)
    unless usuario
      flash.now[:alert] = "Usuário não encontrado."
      @usuario_email = email
      return render :new_reset, status: :not_found
    end

    # Sem validação de token – redefine direto pela combinação email + senha
    if usuario.update(password: password)
      redirect_to login_path, notice: "Senha redefinida com sucesso. Agora você já pode fazer login."
    else
      @usuario_email = email
      @errors = usuario.errors.full_messages
      flash.now[:alert] = "Erro ao redefinir senha."
      render :new_reset, status: :unprocessable_entity
    end
  end
end
