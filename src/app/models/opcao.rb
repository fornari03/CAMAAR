class Opcao < ApplicationRecord
  self.table_name = "opcoes"
  belongs_to :questao

  validates :texto_opcao, presence: true
end
