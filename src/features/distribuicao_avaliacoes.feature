# language: pt
Funcionalidade: Distribuição de Formulários de Avaliação
  Como Administrador
  Eu quero distribuir um template de avaliação para uma ou mais turmas
  Para que os participantes (alunos e professores) possam responder à avaliação

  Contexto:
    Dado que eu estou logado como administrador
    E que existe um template de avaliação "Avaliação Semestral"
    E que existe a turma "Engenharia de Software" com 5 alunos matriculados
    E que existe a turma "Banco de Dados" com 3 alunos matriculados

  @happy_path
  Cenário: Admin distribui formulário para múltiplas turmas
    Dado que eu estou na página de distribuição de formulários
    Quando eu seleciono o template de avaliação "Avaliação Semestral"
    E eu seleciono as turmas para distribuição "Engenharia de Software" e "Banco de Dados"
    E eu clico no botão de distribuição "Distribuir Formulário"
    Então eu devo ver a mensagem de sucesso de distribuição "Formulário distribuído com sucesso para 2 turmas"
    E a turma "Engenharia de Software" deve ter um formulário associado ao template "Avaliação Semestral"
    E todos os 5 alunos da turma "Engenharia de Software" devem ter uma resposta pendente para este formulário
    E a turma "Banco de Dados" deve ter um formulário associado ao template "Avaliação Semestral"

  @sad_path
  Cenário: Admin tenta distribuir sem selecionar turmas
    Dado que eu estou na página de distribuição de formulários
    Quando eu seleciono o template de avaliação "Avaliação Semestral"
    E eu clico no botão de distribuição "Distribuir Formulário"
    Então eu devo ver a mensagem de erro de distribuição "Selecione pelo menos uma turma"
