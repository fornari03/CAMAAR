class Turma < ApplicationRecord
  belongs_to :materia
  belongs_to :docente, class_name: 'Usuario', foreign_key: 'id_docente'
  has_many :formularios
  has_many :matriculas, foreign_key: 'id_turma'
  has_many :alunos, through: :matriculas, source: :usuario

  validates :codigo, presence: true
  validates :semestre, presence: true
  validates :horario, presence: true

  def distribuir_formulario(template)
    ActiveRecord::Base.transaction do
      form = Formulario.create!(
        template: template,
        turma: self,
        titulo_envio: template.titulo || template.name,
        data_criacao: Time.current
      )

      participantes = alunos.to_a + [docente]
      participantes.uniq.each do |participante|
        Resposta.create!(
          formulario: form,
          participante: participante,
          respondido: false
        )
      end
    end
  end
end
