# Controlador base da aplicação, contendo lógica compartilhada de autenticação.
class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  helper_method :current_usuario, :logged_in?

  # Retorna o usuário atualmente autenticado na sessão.
  #
  # Argumentos:
  #   - Nenhum
  #
  # Retorno:
  #   - (Usuario): O usuário logado ou nil.
  #
  # Efeitos Colaterais:
  #   - Consulta ao banco de dados (memoized).
  def current_usuario
    @current_usuario ||= Usuario.find_by(id: session[:usuario_id])
  end

  # Filtro para requerer autenticação de qualquer usuário.
  #
  # Argumentos:
  #   - Nenhum
  #
  # Retorno:
  #   - (NilClass): Redireciona se não logado.
  #
  # Efeitos Colaterais:
  #   - Redireciona para login_path com alerta.
  def authenticate_usuario
    redirect_to login_path, alert: "Faça login para continuar." unless current_usuario.present?
  end

  # Filtro para requerer autenticação de administrador.
  #
  # Argumentos:
  #   - Nenhum
  #
  # Retorno:
  #   - (NilClass): Redireciona se não for admin.
  #
  # Efeitos Colaterais:
  #   - Redireciona para root_path com alerta.
  def authenticate_admin
    redirect_to root_path, alert: "Acesso negado." unless current_usuario&.admin?
  end

  # Verifica se existe um usuário logado.
  #
  # Argumentos:
  #   - Nenhum
  #
  # Retorno:
  #   - (Boolean): True se existe usuário logado, false caso contrário.
  #
  # Efeitos Colaterais:
  #   - Nenhum.
  def logged_in?
    current_usuario.present?
  end

  # Alias/Filtro para exigir login (similar a authenticate_usuario).
  #
  # Argumentos:
  #   - Nenhum
  #
  # Retorno:
  #   - (NilClass): Redireciona se não logado.
  #
  # Efeitos Colaterais:
  #   - Redireciona para login_path.
  def require_login
    unless logged_in?
      redirect_to login_path, alert: "Você precisa estar logado para acessar esta página."
    end
  end
end
