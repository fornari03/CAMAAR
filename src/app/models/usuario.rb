# pode ficar em app/models/usuario.rb (em cima da classe) ou em um arquivo próprio
class AuthenticationError < StandardError; end

class Usuario < ApplicationRecord
  has_secure_password

  #define a senha atual
  attr_accessor :current_password

  enum :ocupacao, { discente: 0, docente: 1, admin: 2 }

  # Validações de campos básicos
  validates :nome,      presence: true
  validates :email,     presence: true, uniqueness: true
  validates :matricula, presence: true
  validates :usuario,   presence: true, uniqueness: true
  validates :ocupacao,  presence: true
  validates :status,    inclusion: { in: [true, false] }


  # Associations
  has_many :turmas_lecionadas, class_name: 'Turma', foreign_key: 'id_docente', dependent: :destroy
  has_many :templates_criados, class_name: 'Template', foreign_key: 'id_criador'
  has_many :respostas, class_name: 'Resposta', foreign_key: 'id_participante'
  has_and_belongs_to_many :turmas, join_table: 'matriculas', foreign_key: 'id_usuario', association_foreign_key: 'id_turma', dependent: :destroy

  # método de autenticação para login (usando :usuario)
  def self.authenticate(usuario, password)
    user = find_by(usuario: usuario)
    raise AuthenticationError, "Usuário não encontrado" unless user
    raise AuthenticationError, "Senha incorreta"        unless user.authenticate(password)
    user
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
