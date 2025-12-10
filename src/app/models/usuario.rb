# pode ficar em app/models/usuario.rb (em cima da classe) ou em um arquivo próprio
class AuthenticationError < StandardError; end

class Usuario < ApplicationRecord
  has_secure_password
  has_many :respostas, foreign_key: 'id_participante'

  #define a senha atual
  attr_accessor :current_password

  #define a senha atual
  attr_accessor :current_password

  enum :ocupacao, { discente: 0, docente: 1, admin: 2 }

  # Validações de campos básicos
  validates :nome,      presence: true
  validates :email,     presence: true, uniqueness: true, allow_nil: true
  validates :matricula, presence: true
  validates :usuario,   presence: true, uniqueness: true
  validates :ocupacao,  presence: true
  validates :status,    inclusion: { in: [true, false] }

  def pendencias
    # Returns pending responses (Resposta objects with data_submissao: nil)
    # This matches the expectation of avaliacoes/index.html.erb
    respostas.where(data_submissao: nil)
  end


  # Associations
  has_many :turmas_lecionadas, class_name: 'Turma', foreign_key: 'id_docente', dependent: :destroy
  has_many :templates_criados, class_name: 'Template', foreign_key: 'id_criador'
  has_many :matriculas, foreign_key: 'id_usuario'
  has_many :turmas, through: :matriculas

  # método de autenticação para login (usando :usuario, :email ou :matricula)
  def self.authenticate(login, password)
    # tenta achar pelo campo usuario, email ou matricula
    user = find_by(usuario: login) ||
           find_by(email: login)   ||
           find_by(matricula: login)

    # usuário não encontrado
    raise AuthenticationError, "Usuário não encontrado" unless user

    # usuário pendente
    if user.status == false
      raise AuthenticationError,
            "Sua conta está pendente. Por favor, redefina sua senha para ativar."
    end

    # senha incorreta
    unless user.authenticate(password)
      raise AuthenticationError, "Senha incorreta"
    end

    user
  end

  def admin?
  ocupacao == "admin"
  end


  private

  def validate_current_password
    return if current_password.blank?   # evita erro antes de preencher

    # compara senha atual digitada com o password_digest
    unless authenticate(current_password)
      errors.add(:current_password, "está incorreta")
    end
  end
end
