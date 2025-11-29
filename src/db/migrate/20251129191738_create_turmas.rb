class CreateTurmas < ActiveRecord::Migration[8.0]
  def change
    create_table :turmas do |t|
      t.string :codigo
      t.string :semestre
      t.string :horario
      t.references :materia, null: false, foreign_key: { to_table: :materias }
      t.integer :id_docente, null: false

      t.timestamps
    end
    add_foreign_key :turmas, :usuarios, column: :id_docente
    add_index :turmas, :id_docente
  end
end
