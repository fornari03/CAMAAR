class CreateMatriculas < ActiveRecord::Migration[8.0]
  def change
    create_table :matriculas do |t|
      t.integer :id_usuario
      t.integer :id_turma

      t.timestamps
    end
  end
end
