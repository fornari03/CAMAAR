# Representa um formulário de avaliação gerado a partir de um Template para uma Turma.
# Armazena os metadados do envio e relaciona o template à turma e às respostas.
class Formulario < ApplicationRecord
  belongs_to :template
  belongs_to :turma
  has_many :respostas

  validates :titulo_envio, presence: true
  validates :data_criacao, presence: true
end
