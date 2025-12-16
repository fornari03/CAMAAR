# Representa a submissão completa de um formulário por um participante.
# Agrupa todos os itens de resposta (RespostaItem).
class Resposta < ApplicationRecord
  belongs_to :formulario
  belongs_to :participante, class_name: 'Usuario', foreign_key: 'id_participante'
  has_many :resposta_items
  
  validates :id_participante, uniqueness: { scope: :formulario_id }
  
  # Verifica se a resposta foi submetida (finalizada).
  #
  # Argumentos:
  #   - Nenhum
  #
  # Retorno:
  #   - (Boolean): Retorna true se data_submissao estiver presente.
  #
  # Efeitos Colaterais:
  #   - Nenhum.
  def respondido?
    data_submissao.present?
  end
end
