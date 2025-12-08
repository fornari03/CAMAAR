# language: pt
Funcionalidade: Painel de Avaliações Pendentes
  Como Participante (Aluno ou Docente)
  Eu quero ver uma lista de avaliações pendentes
  Para que eu possa saber quais formulários preciso responder

  Contexto:
    Dado que eu sou um aluno matriculado na turma "Engenharia de Software"
    E que o administrador distribuiu o template "Avaliação Semestral" para a turma "Engenharia de Software"
    E que eu ainda não respondi a este formulário

  @happy_path
  Cenário: Aluno visualiza avaliação pendente no dashboard
    Dado que eu estou logado como aluno
    Quando eu acesso o meu painel de avaliações
    Então eu devo ver "Avaliação Semestral" na lista de pendências
    E o item deve indicar a turma "Engenharia de Software"
    E eu devo ver um link para "Responder"

  @happy_path
  Cenário: Aluno não vê avaliações já respondidas
    Dado que eu estou logado como aluno
    E que eu já respondi a avaliação "Avaliação Semestral" da turma "Engenharia de Software"
    Quando eu acesso o meu painel de avaliações
    Então eu não devo ver "Avaliação Semestral" na lista de pendências
