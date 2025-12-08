# language: pt
# features/visualizar_templates.feature

Funcionalidade: Visualização dos templates criados
  Como Administrador
  Quero visualizar os templates que criei
  A fim de poder editar e/ou deletar um template

  @happy_path
  Cenário: Visualização com sucesso
    Dado que estou logado
    Dado que existe um template criado com o campo "nome_da_matéria" preenchido com "Engenharia de Software", e o campo "semestre" preenchido com "2025.1", e o campo "professor" preenchido com "Genaína"
    E estou na página "Gerenciamento de templates"
    Então devo ver um cartão da disciplina contendo: "Engenharia de Software","2025.1","Genaína"

  @sad_path
  Cenário: Não existem templates
    Dado que estou logado
    Dado que não existe nenhum template criado
    E estou na página "Gerenciamento de templates"
    Então devo visualizar a mensagem "Não existe nenhuma avaliação até o momento"
