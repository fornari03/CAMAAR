class Resposta < ApplicationRecord
  belongs_to :formulario
  belongs_to :participante, class_name: 'Usuario', foreign_key: 'id_participante'
  has_many :resposta_items

  validates :data_submissao, presence: true
end
