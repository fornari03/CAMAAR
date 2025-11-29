class Questao < ApplicationRecord
  belongs_to :template
  has_many :opcoes
  has_many :resposta_items

  enum :tipo, { texto: 0, multipla_escolha: 1 }

  validates :enunciado, presence: true
  validates :tipo, presence: true
end
