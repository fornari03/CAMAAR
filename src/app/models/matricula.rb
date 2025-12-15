# Tabela associativa que representa a matrícula de um usuário (aluno) em uma turma.
# Utilizada para gerenciar a relação N:N entre Usuario e Turma.
class Matricula < ApplicationRecord
  belongs_to :usuario, foreign_key: 'id_usuario'
  belongs_to :turma, foreign_key: 'id_turma'
end
