# Erro personalizado para falhas de autenticação.
class AuthenticationError < StandardError; end

# Representa um usuário do sistema (Discente, Docente ou Admin).
# Gerencia autenticação, autorização e relacionamentos com turmas e formulários.
class Usuario < ApplicationRecord
  has_secure_password
  has_many :respostas, foreign_key: 'id_participante'

  # Acessor virtual para a senha atual (usado na mudança de senha).
  attr_accessor :current_password

  enum :ocupacao, { discente: 0, docente: 1, admin: 2 }

  # Validações de campos básicos
  validates :nome,      presence: true
  validates :email,     presence: true, uniqueness: true, allow_nil: true
  validates :matricula, presence: true
  validates :usuario,   presence: true, uniqueness: true
  validates :ocupacao,  presence: true
  validates :status,    inclusion: { in: [true, false] }

  validate :validate_current_password

  # Retorna as respostas pendentes (formulários não submetidos) do usuário.
  #
  # Retorno:
  #   - (ActiveRecord::Relation): Uma coleção de objetos Resposta com data_submissao nil.
  def pendencias
    respostas.where(data_submissao: nil)
  end

  # Associations
  has_many :turmas_lecionadas, class_name: 'Turma', foreign_key: 'id_docente', dependent: :destroy
  has_many :templates_criados, class_name: 'Template', foreign_key: 'id_criador'
  has_many :matriculas, foreign_key: 'id_usuario'
  has_many :turmas, through: :matriculas

  # Autentica um usuário pelo login (usuário, email ou matrícula) e senha.
  #
  # Argumentos:
  #   - login (String): O identificador do usuário.
  #   - password (String): A senha do usuário.
  #
  # Retorno:
  #   - (Usuario): O objeto do usuário autenticado se as credenciais forem válidas.
  #
  # Efeitos Colaterais:
  #   - Realiza consultas ao banco de dados.
  #   - Dispara AuthenticationError se falhar.
  def self.authenticate(login, password)
    user = find_by(usuario: login) ||
           find_by(email: login)   ||
           find_by(matricula: login)

    raise AuthenticationError, "Usuário não encontrado" unless user

    if user.status == false
      raise AuthenticationError, "Sua conta está pendente. Por favor, redefina sua senha para ativar."
    end

    unless user.authenticate(password)
      raise AuthenticationError, "Senha incorreta"
    end

    user
  end

  # Verifica se o usuário possui a ocupação de administrador.
  #
  # Retorno:
  #   - (Boolean): Retorna true se a ocupação for 'admin'.
  def admin?
    ocupacao == "admin"
  end

  private

  # Valida a senha atual do usuário.
  #
  # Efeitos Colaterais:
  #   - Adiciona um erro ao modelo se a autenticação falhar.
  def validate_current_password
    return if current_password.blank?

    unless authenticate(current_password)
      errors.add(:current_password, "está incorreta")
    end
  end
end