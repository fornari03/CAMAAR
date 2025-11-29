class RespostaItem < ApplicationRecord
  belongs_to :resposta
  belongs_to :questao
  belongs_to :opcao_escolhida, class_name: 'Opcao', foreign_key: 'id_opcao_escolhida', optional: true

  validate :valida_resposta_conforme_tipo_questao

  private

  def valida_resposta_conforme_tipo_questao
    return unless questao

    if questao.texto? && texto_resposta.blank?
      errors.add(:texto_resposta, 'não pode ficar em branco para questões de texto')
    elsif questao.multipla_escolha? && opcao_escolhida.nil?
      errors.add(:opcao_escolhida, 'deve ser selecionada para questões de múltipla escolha')
    end
  end
end
