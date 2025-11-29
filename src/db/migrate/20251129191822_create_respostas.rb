class CreateRespostas < ActiveRecord::Migration[8.0]
  def change
    create_table :respostas do |t|
      t.datetime :data_submissao
      t.references :formulario, null: false, foreign_key: true
      t.integer :id_participante, null: false

      t.timestamps
    end
    add_foreign_key :respostas, :usuarios, column: :id_participante
    add_index :respostas, :id_participante
  end
end
