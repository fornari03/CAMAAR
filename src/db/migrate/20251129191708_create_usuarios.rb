class CreateUsuarios < ActiveRecord::Migration[8.0]
  def change
    create_table :usuarios do |t|
      t.string :nome
      t.string :email
      t.string :matricula
      t.string :usuario
      t.string :password_digest
      t.integer :ocupacao
      t.boolean :status

      t.timestamps
    end
  end
end
