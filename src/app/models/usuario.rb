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

  # 🔥 Validação de senha obrigatória e igual à confirmação
  validates :password,
            presence: { message: "a senha não pode ser vazia" },
            length: { minimum: 6, message: "precisa ter no mínimo 6 caracteres" },
            confirmation: { message: "não confere com a confirmação" }


  # Associations
  has_many :turmas_lecionadas, class_name: 'Turma',    foreign_key: 'id_docente'
  has_many :templates_criados, class_name: 'Template', foreign_key: 'id_criador'
  has_many :templates_criados, class_name: 'Template', foreign_key: 'id_criador'
  has_many :respostas,         class_name: 'Resposta', foreign_key: 'id_participante'
  has_and_belongs_to_many :turmas, join_table: 'matriculas', foreign_key: 'id_usuario', association_foreign_key: 'id_turma'

  # método de autenticação para login (usando :usuario)
  def self.authenticate(login, password)
    # tenta achar pelo campo usuario, email ou matricula
    user = find_by(usuario: login) ||
           find_by(email: login)   ||
           find_by(matricula: login)

    # usuário não encontrado
    raise AuthenticationError, "Login ou senha inválidos" unless user

    # usuário pendente (ajuste conforme seu tipo de status)
    if user.status == false  # supondo boolean: false = pendente, true = ativo
      raise AuthenticationError,
            "Sua conta está pendente. Por favor, redefina sua senha para ativar."
    end

    # senha incorreta
    unless user.authenticate(password)
      raise AuthenticationError, "Login ou senha inválidos"
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
