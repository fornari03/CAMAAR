# Modelo temporário/auxiliar para lidar com a criação dinâmica de questões em templates na interface.
# Permite serializar o conteúdo das alternativas como JSON.
class TemplateQuestion < ApplicationRecord
  belongs_to :template
  
  enum :question_type, { text: 'text', radio: 'radio', checkbox: 'checkbox' }, suffix: true
  
  validates :title, presence: { message: "o texto da questão é obrigatório" }
  validate :alternatives_must_be_present, if: -> { ['radio', 'checkbox'].include?(question_type) }

  # Valida se as alternativas estão preenchidas para perguntas de rádio ou checkbox.
  #
  # Argumentos:
  #   - Nenhum
  #
  # Retorno:
  #   - (NilClass): Retorna nil se a validação passar.
  #
  # Efeitos Colaterais:
  #   - Adiciona erro ao modelo se as alternativas estiverem em branco.
  def alternatives_must_be_present
    if content.blank? || content.any?(&:blank?)
      errors.add(:base, "Todas as alternativas devem ser preenchidas")
    end
  end

  serialize :content, coder: JSON
end
