# Representa uma turma de uma disciplina em um período letivo.
# Relaciona docentes, alunos e formulários de avaliação.
class Turma < ApplicationRecord
  belongs_to :materia
  belongs_to :docente, class_name: 'Usuario', foreign_key: 'id_docente'
  has_many :formularios
  has_many :matriculas, foreign_key: 'id_turma'
  has_many :alunos, through: :matriculas, source: :usuario

  validates :codigo, presence: true
  validates :semestre, presence: true
  validates :horario, presence: true

  # Cria e distribui um formulário baseado em um template para todos os alunos e docente da turma.
  #
  # Argumentos:
  #   - template (Template): O template base para o formulário.
  #
  # Retorno:
  #   - (Array<Resposta>): Uma lista de objetos Resposta criados (para cada participante).
  #
  # Efeitos Colaterais:
  #   - Cria um novo registro Formulario.
  #   - Cria múltiplos registros Resposta (um para cada aluno e um para o docente).
  #   - Executa dentro de uma transação.
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

        )
      end
    end
  end

  # Retorna o nome completo da turma (Matéria - Código).
  #
  # Argumentos:
  #   - Nenhum
  #
  # Retorno:
  #   - (String): O nome concatenado com o código.
  #
  # Efeitos Colaterais:
  #   - Nenhum.
  def nome_completo
    "#{materia&.nome} - #{codigo}"
  end
end
