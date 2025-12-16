# Representa uma questão individual dentro de um template de avaliação.
# Pode ser do tipo texto ou múltipla escolha.
class Questao < ApplicationRecord
  self.table_name = "questoes"
  belongs_to :template
  has_many :opcoes, class_name: 'Opcao', dependent: :destroy
  has_many :resposta_items, dependent: :destroy

  enum :tipo, { texto: 0, multipla_escolha: 1 }

  validates :enunciado, presence: true
  validates :tipo, presence: true
end
