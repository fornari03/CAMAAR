class AutenticacaoController < ApplicationController
  skip_before_action :require_login, only: [:new, :create], raise: false
  layout "auth" # Mantendo o layout que configuramos antes

  def new
    # Renderiza a página de login
  end

  def create
    login = params[:email]  # Field is named :email but accepts email/matricula/usuario
    password = params[:password]

    begin
      @usuario = Usuario.authenticate(login, password)
      session[:usuario_id] = @usuario.id

      if @usuario.admin?
        redirect_to admin_gerenciamento_path, notice: "Bem-vindo, Administrador!"
      else
        redirect_to root_path, notice: "Login realizado com sucesso!"
      end
    rescue AuthenticationError => e
      flash.now[:alert] = e.message
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:usuario_id] = nil
    redirect_to login_path, notice: "Deslogado com sucesso."
  end
end