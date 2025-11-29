class Materia < ApplicationRecord
  validates :codigo, presence: true
  validates :nome, presence: true

  has_many :turmas
end
