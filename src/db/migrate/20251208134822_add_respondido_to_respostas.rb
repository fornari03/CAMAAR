class AddRespondidoToRespostas < ActiveRecord::Migration[8.0]
  def change
    add_column :respostas, :respondido, :boolean, default: false
  end
end
