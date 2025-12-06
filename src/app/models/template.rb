class Template < ApplicationRecord
  belongs_to :criador, class_name: 'Usuario', foreign_key: 'id_criador', optional: true
  has_many :questoes
  has_many :formularios
  has_many :template_questions, dependent: :destroy

  validates :titulo, presence: true
  # validates :titulo, presence: true # Keeping existing validation if needed, but user wants name
  
  scope :all_visible, -> { where(hidden: false) }
end
