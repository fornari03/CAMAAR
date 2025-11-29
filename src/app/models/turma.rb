class Turma < ApplicationRecord
  belongs_to :materia
  belongs_to :docente, class_name: 'Usuario', foreign_key: 'id_docente'
  has_many :formularios

  validates :codigo, presence: true
  validates :semestre, presence: true
  validates :horario, presence: true
end
