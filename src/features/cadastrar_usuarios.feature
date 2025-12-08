# language: pt
# features/autenticacao.feature

Funcionalidade: Cadastrar usuários do sistema (e enviar convite por email)
  Eu como Administrador
  Quero cadastrar participantes de turmas do SIGAA ao importar dados de usuarios novos para o sistema
  A fim de que eles acessem o sistema CAMAAR

  Contexto:
    Dado que eu estou logado como Administrador
    E estou na página "Gerenciamento"

  @happy_path
  Cenário: Importar um usuário que é novo no sistema
    Dado que o sigaa contém o usuário "Fulano de Tal" ("150084006") com e-mail "fulano@gmail.com"
    E que o sistema não possui o usuário "Fulano de Tal" ("150084006") cadastrado
    Quando eu solicito a importação clicando em "Importar dados"
    Então o usuário "Fulano de Tal" ("150084006") deve ser criado no sistema com o status "pendente"
    E um e-mail de "Definição de Senha" deve ser enviado para "fulano@gmail.com"
    E eu devo ver a mensagem de sucesso "Dados importados com sucesso!"

  @happy_path
  Cenário: Importar um usuário que já existe no sistema
    Dado que o sigaa contém o usuário "Fulano de Tal" ("150084006")
    E que o sistema possui o usuário "Fulano de Tal" ("150084006") cadastrado (seja pendente ou ativo)
    Quando eu solicito a importação clicando em "Importar dados"
    Então nenhum novo e-mail de "Definição de Senha" deve ser enviado para "150084006"
    E nenhum usuário duplicado deve ser criado

  @sad_path
  Cenário: Importar um novo usuário que não possui e-mail
    Dado que o sigaa contém o usuário "Usuário Sem Email" ("190099999")
    Mas o usuário "190099999" não possui um endereço de e-mail
    Quando eu solicito a importação clicando em "Importar dados"
    Então o usuário "190099999" não deve ser criado no sistema
    E eu devo ver uma mensagem de erro "Falha ao importar usuário '190099999': e-mail ausente."