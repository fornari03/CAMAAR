class Template < ApplicationRecord
  belongs_to :criador, class_name: 'Usuario', foreign_key: 'id_criador'
  has_many :questoes
  has_many :formularios

  validates :titulo, presence: true
  validates :participantes, presence: true
end
