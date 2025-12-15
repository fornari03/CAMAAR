# Gerencia o ciclo de vida da autenticação (Login e Logout).
class AutenticacaoController < ApplicationController
  skip_before_action :require_login, only: %i[new create], raise: false
  layout "auth"

  # Renderiza a página de formulário de login.
  #
  # Argumentos:
  #   - Nenhum
  #
  # Retorno:
  #   - (NilClass): Renderiza a view new.
  #
  # Efeitos Colaterais:
  #   - Nenhum.
  def new
    # Renderiza a página de login
  end

  # Processa o envio do formulário de login.
  #
  # Argumentos:
  #   - params[:email] (String): Login digitado pelo usuário.
  #   - params[:password] (String): Senha.
  #
  # Retorno:
  #   - (NilClass): Redireciona em sucesso.
  #
  # Efeitos Colaterais:
  #   - Consulta DB.
  #   - Cria sessão se sucesso.
  #   - Chama handle_auth_failure se erro.
  def create
    user = Usuario.authenticate(params[:email], params[:password])

    initialize_session(user)
    redirect_based_on_role(user)

  rescue AuthenticationError => e
    handle_auth_failure(e)
  end

  # Realiza o logout do usuário.
  #
  # Argumentos:
  #   - Nenhum
  #
  # Retorno:
  #   - (NilClass): Redireciona para login_path.
  #
  # Efeitos Colaterais:
  #   - Reseta sessão.
  #   - Remove cookie auth_token.
  def destroy
    reset_session
    cookies.delete(:auth_token)
    redirect_to login_path, notice: "Deslogado com sucesso."
  end

  private

  # Inicializa a sessão do usuário.
  #
  # Argumentos:
  #   - user (Usuario): O usuário autenticado.
  #
  # Retorno:
  #   - (Integer): O ID salvo na sessão.
  #
  # Efeitos Colaterais:
  #   - Grava session[:usuario_id].
  def initialize_session(user)
    session[:usuario_id] = user.id
  end

  # Redireciona o usuário para a página apropriada baseada no seu papel.
  #
  # Argumentos:
  #   - user (Usuario): O usuário.
  #
  # Retorno:
  #   - (NilClass): Redireciona.
  #
  # Efeitos Colaterais:
  #   - Redireciona para admin_gerenciamento_path ou root_path.
  def redirect_based_on_role(user)
    if user.admin?
      redirect_to admin_gerenciamento_path, notice: "Bem-vindo, Administrador!"
    else
      redirect_to root_path, notice: "Login realizado com sucesso!"
    end
  end

  # Lida com falhas de autenticação.
  #
  # Argumentos:
  #   - exception (StandardError): Exceção capturada.
  #
  # Retorno:
  #   - (NilClass): Redireciona para login_path.
  #
  # Efeitos Colaterais:
  #   - Redireciona com alerta.
  def handle_auth_failure(exception)
    redirect_to login_path, alert: exception.message
  end
end