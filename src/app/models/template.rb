# Define a estrutura de uma avaliação, contendo um conjunto de questões.
# Serve de base para a criação dos Formulários.
class Template < ApplicationRecord
  belongs_to :criador, class_name: 'Usuario', foreign_key: 'id_criador', optional: true
  has_many :questoes, class_name: 'Questao'
  has_many :formularios
  has_many :template_questions, dependent: :destroy

  validates :titulo, presence: { message: "Nome do Template não pode ficar em branco" }
  # validates :titulo, presence: true # Keeping existing validation if needed, but user wants name
  
  scope :all_visible, -> { where(hidden: false) }
end
