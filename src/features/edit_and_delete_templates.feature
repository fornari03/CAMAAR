# language: pt
Funcionalidade: Editar e Deletar Templates
  Como um Administrador
  Eu quero editar e deletar templates
  Para que eu possa gerenciar os formulários disponíveis no sistema

  Contexto:
    Dado que eu estou logado como administrador
    E que existe um template chamado "Template Antigo"

  Cenário: Editar nome do template
    Dado que eu estou na página de edição de "Template Antigo"
    Quando eu preencho o campo do template "Nome" com "Template Novo"
    E eu clico no botão do template "Atualizar Nome"
    Então eu devo ver a mensagem do template "Template atualizado com sucesso"
    E o nome do template deve ser "Template Novo"

  Cenário: Adicionar uma questão ao template
    Dado que eu estou na página de edição de "Template Antigo"
    Quando eu clico no botão do template "Adicionar Questão"
    Então eu devo ver um formulário de nova questão
    E o número total de questões deve ser 1

  Cenário: Exclusão lógica de um template
    Dado que eu estou na página de listagem de templates
    Quando eu clico em "Deletar" para "Template Antigo"
    Então eu não devo ver "Template Antigo"
    Mas o template "Template Antigo" deve continuar existindo no banco de dados
