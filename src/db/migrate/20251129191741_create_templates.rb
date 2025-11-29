class CreateTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :templates do |t|
      t.string :titulo
      t.string :participantes
      t.integer :id_criador, null: false

      t.timestamps
    end
    add_foreign_key :templates, :usuarios, column: :id_criador
    add_index :templates, :id_criador
  end
end
