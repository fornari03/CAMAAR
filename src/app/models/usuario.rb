# pode ficar em app/models/usuario.rb (em cima da classe) ou em um arquivo próprio
class AuthenticationError < StandardError; end

class Usuario < ApplicationRecord
  has_secure_password

  # Define a senha atual (para validação opcional em updates)
  attr_accessor :current_password

  enum :ocupacao, { discente: 0, docente: 1, admin: 2 }

  # Validações de campos básicos
  validates :nome,      presence: true
  validates :email,     presence: true, uniqueness: true
  validates :matricula, presence: true
  validates :usuario,   presence: true, uniqueness: true
  validates :ocupacao,  presence: true
  validates :status,    inclusion: { in: [true, false] }

  # Validação de senha
  validates :password,
            presence:   { message: "a senha não pode ser vazia" },
            length:     { minimum: 6, message: "precisa ter no mínimo 6 caracteres" },
            confirmation: { message: "não confere com a confirmação" },
            if: :password_required?

  # Associations
  has_many :respostas,         class_name: 'Resposta', foreign_key: 'id_participante'
  has_many :turmas_lecionadas, class_name: 'Turma',    foreign_key: 'id_docente', dependent: :destroy
  has_many :templates_criados, class_name: 'Template', foreign_key: 'id_criador'

  # 🔹 Relação via Matricula (JEITO ESCOLHIDO)
  has_many :matriculas, foreign_key: 'id_usuario', dependent: :destroy
  has_many :turmas,     through: :matriculas

  # 🚫 REMOVIDO: has_and_belongs_to_many :turmas (conflitava com o through)

  # método de autenticação para login (usando :usuario)
  def self.authenticate(usuario, password)
    user = find_by(usuario: usuario) || find_by(matricula: usuario) || find_by(email: usuario)
    raise AuthenticationError, "Usuário não encontrado" unless user
    raise AuthenticationError, "Senha incorreta"        unless user.authenticate(password)
    user
  end

  private

  # Validação opcional de senha atual (se você quiser usar isso em forms de "alterar senha")
  def validate_current_password
    return if current_password.blank?   # evita erro antes de preencher

    unless authenticate(current_password)
      errors.add(:current_password, "está incorreta")
    end
  end

  # Evita exigir senha em TODO update, caso não esteja mudando a senha
  def password_required?
    password_digest.blank? || !password.nil?
  end
end
