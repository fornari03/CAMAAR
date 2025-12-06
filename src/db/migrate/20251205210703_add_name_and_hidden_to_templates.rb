class AddNameAndHiddenToTemplates < ActiveRecord::Migration[8.0]
  def change
    add_column :templates, :name, :string
    add_column :templates, :hidden, :boolean, default: false
  end
end
