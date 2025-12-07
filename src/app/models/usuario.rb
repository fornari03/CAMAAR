class Usuario < ApplicationRecord
  has_secure_password

  enum :ocupacao, { discente: 0, docente: 1, admin: 2 }

  validates :nome, presence: true
  validates :email, presence: true, uniqueness: true
  validates :matricula, presence: true
  validates :usuario, presence: true, uniqueness: true
  validates :ocupacao, presence: true
  validates :status, inclusion: { in: [true, false] }

  # Associations
  has_many :turmas_lecionadas, class_name: 'Turma', foreign_key: 'id_docente'
  has_many :templates_criados, class_name: 'Template', foreign_key: 'id_criador'
  has_many :respostas, class_name: 'Resposta', foreign_key: 'id_participante'
  has_and_belongs_to_many :turmas, join_table: 'matriculas', foreign_key: 'id_usuario', association_foreign_key: 'id_turma'
end
