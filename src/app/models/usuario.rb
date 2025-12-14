class AuthenticationError < StandardError; end

class Usuario < ApplicationRecord
  has_secure_password
  has_many :respostas, foreign_key: 'id_participante'

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

  def pendencias
    respostas.where(data_submissao: nil)
  end

  # Associations
  has_many :turmas_lecionadas, class_name: 'Turma', foreign_key: 'id_docente', dependent: :destroy
  has_many :templates_criados, class_name: 'Template', foreign_key: 'id_criador'
  has_many :matriculas, foreign_key: 'id_usuario'
  has_many :turmas, through: :matriculas

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

  def admin?
    ocupacao == "admin"
  end

  private

  def validate_current_password
    return if current_password.blank?

    unless authenticate(current_password)
      errors.add(:current_password, "está incorreta")
    end
  end
end