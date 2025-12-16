# Representa uma disciplina ou matéria ofertada pela instituição.
# Contém informações como código (ex: CIC0105) e nome.
class Materia < ApplicationRecord
  validates :codigo, presence: true
  validates :nome, presence: true

  has_many :turmas
end
