class TemplateQuestion < ApplicationRecord
  belongs_to :template
  
  enum :question_type, { text: 'text', radio: 'radio', checkbox: 'checkbox' }, suffix: true
  
  validates :title, presence: { message: "o texto da questão é obrigatório" }
  validate :alternatives_must_be_present, if: -> { ['radio', 'checkbox'].include?(question_type) }

  def alternatives_must_be_present
    if content.blank? || content.any?(&:blank?)
      errors.add(:base, "Todas as alternativas devem ser preenchidas")
    end
  end

  serialize :content, coder: JSON
end
