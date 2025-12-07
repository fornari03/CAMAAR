# language: pt
# features/atualizar_dados_sigaa.feature

Funcionalidade: Atualizar base de dados com os dados do SIGAA
  Eu como Administrador
  Quero atualizar a base de dados já existente com os dados atuais do sigaa
  A fim de corrigir a base de dados do sistema.

  Contexto:
    Dado que eu estou logado como Administrador
    E estou na página "gerenciamento"

  @happy_path
  Cenário: Sincronizar participante que mudou de e-mail
    Dado que o sistema possui o usuário "Fulano de Tal" ("150084006") cadastrado com o e-mail "fulano.antigo@email.com"
    E a fonte de dados externa indica que o e-mail de "150084006" agora é "fulano.novo@gmail.com"
    Quando eu solicito a importação clicando em "Importar dados"
    Então o e-mail do usuário "150084006" deve ser atualizado para "fulano.novo@gmail.com"
    E nenhum usuário duplicado deve ser criado
    E eu devo ver a mensagem de sucesso "Dados importados com sucesso!"

  @happy_path
  Cenário: Sincronizar matrícula de participante em nova turma
    Dado que o sistema possui o usuário "Fulano de Tal" ("150084006") cadastrado
    E que o sistema possui a turma "TA" da matéria "CIC0097" cadastrada
    E o usuário "150084006" ainda não está matriculado na turma "TA" da matéria "CIC0097"
    E a fonte de dados externa indica que "150084006" está matriculado na turma "TA" da matéria "CIC0097"
    Quando eu solicito a importação clicando em "Importar dados"
    Então o usuário "150084006" deve ser matriculado na turma "TA" da matéria "CIC0097"
    E eu devo ver a mensagem de sucesso "Dados importados com sucesso!"

  @happy_path
  Cenário: Sincronizar participante que mudou de nome
    Dado que o sistema possui o usuário "Fulano de Tal" ("150084006") cadastrado
    E a fonte de dados externa indica que o nome de "150084006" agora é "Fulano da Silva"
    Quando eu solicito a importação clicando em "Importar dados"
    Então o nome do usuário "150084006" deve ser atualizado para "Fulano da Silva"
    E eu devo ver a mensagem de sucesso "Dados importados com sucesso!"

  @happy_path
  Cenário: Sincronizar matéria que mudou de nome
    Dado que o sistema possui a matéria "CIC0097" cadastrada
    E a fonte de dados externa indica que o nome da matéria "CIC0097" agora é "BANCOS DE DADOS AVANÇADO"
    Quando eu solicito a importação clicando em "Importar dados"
    Então o nome da matéria "CIC0097" deve ser atualizado para "BANCOS DE DADOS AVANÇADO"
    E eu devo ver a mensagem de sucesso "Dados importados com sucesso!"

  @happy_path
  Cenário: Sincronizar participante que foi removido do SIGAA
    Dado que o sistema possui o usuário "Fulano de Tal" ("150084006") cadastrado
    E a fonte de dados externa indica que "150084006" não está mais presente
    Quando eu solicito a importação clicando em "Importar dados"
    Então o usuário "150084006" deve ser excluído do sistema
    E eu devo ver a mensagem de sucesso "Dados importados com sucesso!"

  @sad_path
  Cenário: Falha ao buscar os dados externos
    Dado que o sigaa está indisponível
    Quando eu solicito a importação clicando em "Importar dados"
    Então eu devo ver a mensagem de erro "Não foi possível buscar os dados. Tente novamente mais tarde."
    E nenhuma nova turma deve ser cadastrada no sistema
    E nenhum novo usuário deve ser cadastrado no sistema