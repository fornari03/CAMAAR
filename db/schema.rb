# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_11_29_191826) do
  create_table "formularios", force: :cascade do |t|
    t.string "titulo_envio"
    t.datetime "data_criacao"
    t.integer "template_id", null: false
    t.integer "turma_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["template_id"], name: "index_formularios_on_template_id"
    t.index ["turma_id"], name: "index_formularios_on_turma_id"
  end

  create_table "materias", force: :cascade do |t|
    t.string "codigo"
    t.string "nome"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "opcoes", force: :cascade do |t|
    t.string "texto_opcao"
    t.integer "questao_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["questao_id"], name: "index_opcoes_on_questao_id"
  end

  create_table "questoes", force: :cascade do |t|
    t.text "enunciado"
    t.integer "tipo"
    t.integer "template_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["template_id"], name: "index_questoes_on_template_id"
  end

  create_table "resposta_items", force: :cascade do |t|
    t.text "texto_resposta"
    t.integer "resposta_id", null: false
    t.integer "questao_id", null: false
    t.integer "id_opcao_escolhida"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id_opcao_escolhida"], name: "index_resposta_items_on_id_opcao_escolhida"
    t.index ["questao_id"], name: "index_resposta_items_on_questao_id"
    t.index ["resposta_id"], name: "index_resposta_items_on_resposta_id"
  end

  create_table "respostas", force: :cascade do |t|
    t.datetime "data_submissao"
    t.integer "formulario_id", null: false
    t.integer "id_participante", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["formulario_id"], name: "index_respostas_on_formulario_id"
    t.index ["id_participante"], name: "index_respostas_on_id_participante"
  end

  create_table "templates", force: :cascade do |t|
    t.string "titulo"
    t.string "participantes"
    t.integer "id_criador", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id_criador"], name: "index_templates_on_id_criador"
  end

  create_table "turmas", force: :cascade do |t|
    t.string "codigo"
    t.string "semestre"
    t.string "horario"
    t.integer "materia_id", null: false
    t.integer "id_docente", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id_docente"], name: "index_turmas_on_id_docente"
    t.index ["materia_id"], name: "index_turmas_on_materia_id"
  end

  create_table "usuarios", force: :cascade do |t|
    t.string "nome"
    t.string "email"
    t.string "matricula"
    t.string "usuario"
    t.string "password_digest"
    t.integer "ocupacao"
    t.boolean "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "formularios", "templates"
  add_foreign_key "formularios", "turmas"
  add_foreign_key "opcoes", "questoes", column: "questao_id"
  add_foreign_key "questoes", "templates"
  add_foreign_key "resposta_items", "opcoes", column: "id_opcao_escolhida"
  add_foreign_key "resposta_items", "questoes", column: "questao_id"
  add_foreign_key "resposta_items", "respostas"
  add_foreign_key "respostas", "formularios"
  add_foreign_key "respostas", "usuarios", column: "id_participante"
  add_foreign_key "templates", "usuarios", column: "id_criador"
  add_foreign_key "turmas", "materias"
  add_foreign_key "turmas", "usuarios", column: "id_docente"
end
