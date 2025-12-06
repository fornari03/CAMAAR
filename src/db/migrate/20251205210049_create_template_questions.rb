class CreateTemplateQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :template_questions do |t|
      t.string :title, default: ""
      t.string :question_type, default: "text"
      t.text :content, default: "[]"
      t.references :template, null: false, foreign_key: true

      t.timestamps
    end
  end
end
