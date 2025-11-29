class Formulario < ApplicationRecord
  belongs_to :template
  has_many :respostas

  validates :titulo_envio, presence: true
  validates :data_criacao, presence: true
end
