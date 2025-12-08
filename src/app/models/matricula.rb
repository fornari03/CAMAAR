class Matricula < ApplicationRecord
  belongs_to :usuario, foreign_key: 'id_usuario'
  belongs_to :turma, foreign_key: 'id_turma'
end
