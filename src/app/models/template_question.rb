class TemplateQuestion < ApplicationRecord
  belongs_to :template
  
  enum :question_type, { text: 'text', radio: 'radio', checkbox: 'checkbox' }, suffix: true

  serialize :content, coder: JSON
end
