class Opcao < ApplicationRecord
  belongs_to :questao

  validates :texto_opcao, presence: true
end
