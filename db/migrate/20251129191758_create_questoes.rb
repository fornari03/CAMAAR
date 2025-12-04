class CreateQuestoes < ActiveRecord::Migration[8.0]
  def change
    create_table :questoes do |t|
      t.text :enunciado
      t.integer :tipo
      t.references :template, null: false, foreign_key: true

      t.timestamps
    end
  end
end
