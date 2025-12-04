class CreateRespostaItems < ActiveRecord::Migration[8.0]
  def change
    create_table :resposta_items do |t|
      t.text :texto_resposta
      t.references :resposta, null: false, foreign_key: { to_table: :respostas }
      t.references :questao, null: false, foreign_key: { to_table: :questoes }
      t.integer :id_opcao_escolhida, null: true

      t.timestamps
    end
    add_foreign_key :resposta_items, :opcoes, column: :id_opcao_escolhida
    add_index :resposta_items, :id_opcao_escolhida
  end
end
