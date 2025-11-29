class CreateOpcoes < ActiveRecord::Migration[8.0]
  def change
    create_table :opcoes do |t|
      t.string :texto_opcao
      t.references :questao, null: false, foreign_key: { to_table: :questoes }

      t.timestamps
    end
  end
end
