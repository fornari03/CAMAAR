# language: pt
# features/visualizacao_resultados_formularios.feature

Funcionalidade: Visualização de resultados dos formulários
  Eu como Administrador
  Quero visualizar os formulários criados
  A fim de gerar um relatório a partir das respostas

Contexto:
  Dado que eu sou um "admin" logado no sistema

Cenário: Visualizar lista de formulários disponíveis (Caminho Feliz)
  Dado que estou na página "dashboard"
  E existem os formulários "Avaliação Docente" e "Avaliação da Infraestrutura"
  Quando eu acesso a página "formularios"
  Então eu devo ver "Avaliação Docente"
  E eu devo ver "Avaliação da Infraestrutura"

Cenário: Visualizar resultados de um formulário específico (Caminho Feliz)
  Dado que existe o formulário "Avaliação Docente"
  E ele possui 30 respostas
  Quando eu acesso a página "formularios/Avaliação Docente"
  Então eu devo ver o relatório consolidado do formulário
  E eu devo ver a mensagem "Total de respostas: 30"

Cenário: Admin tenta visualizar relatório de formulário inexistente (Caminho Triste)
  Quando eu acesso a página "formularios/FormularioInexistente"
  Então eu devo ver a mensagem "Formulário não encontrado"
  E devo permanecer na página "formularios"

Cenário: Não há formulários cadastrados (Caminho Triste)
  Dado que não existe nenhum formulário cadastrado
  Quando eu acesso a página "formularios"
  Então eu devo ver a mensagem "Nenhum formulário cadastrado"

