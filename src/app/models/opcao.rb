# Representa uma opção de resposta para uma questão do tipo Múltipla Escolha.
# Armazena o texto da opção e se relaciona com a questão pai.
class Opcao < ApplicationRecord
  self.table_name = "opcoes"
  belongs_to :questao

  validates :texto_opcao, presence: true
end
