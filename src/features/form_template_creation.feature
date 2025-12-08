# language: pt
Funcionalidade: Criação de Template de Formulário
  Como um Administrador
  Eu quero criar um template definindo seu nome
  Para que eu possa adicionar questões a ele posteriormente

  Cenário: Criar um novo template com sucesso
    Dado que eu estou logado como administrador
    E que eu estou na página de novo template
    Quando eu preencho o campo do template "Nome" com "Avaliação de Disciplina"
    E eu clico no botão do template "Salvar Template"
    Então eu devo ser redirecionado para a página de edição do template "Avaliação de Disciplina"
    E eu devo ver a mensagem do template "Template criado com sucesso"

  Cenário: Tentar criar um template com nome vazio
    Dado que eu estou logado como administrador
    E que eu estou na página de novo template
    Quando eu clico no botão do template "Salvar Template"
    Então eu devo ver a mensagem do template "Nome do Template não pode ficar em branco"
