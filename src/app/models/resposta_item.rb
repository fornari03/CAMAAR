class RespostaItem < ApplicationRecord
  belongs_to :resposta
  belongs_to :questao
  belongs_to :opcao_escolhida, class_name: 'Opcao', foreign_key: 'id_opcao_escolhida', optional: true

  validates :texto_resposta, presence: true, if: -> { opcao_escolhida.nil? }
end
