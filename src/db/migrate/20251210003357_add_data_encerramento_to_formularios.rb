class AddDataEncerramentoToFormularios < ActiveRecord::Migration[8.0]
  def change
    add_column :formularios, :data_encerramento, :datetime
  end
end
