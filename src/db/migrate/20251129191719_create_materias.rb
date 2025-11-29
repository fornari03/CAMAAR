class CreateMaterias < ActiveRecord::Migration[8.0]
  def change
    create_table :materias do |t|
      t.string :codigo
      t.string :nome

      t.timestamps
    end
  end
end
