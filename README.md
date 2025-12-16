# CAMAAR - Sistema de Gestão Acadêmica

Este projeto utiliza **Ruby on Rails 8** e **SQLite**.

## Pré-requisitos

* **Ruby:** Versão 3.2.0 ou superior (Requisito do Rails 8).
* **Bundler:** Para gerenciar as dependências.
* **SQLite3:** Banco de dados utilizado.

## Instalação

1.  **Instale as dependências:**
    ```bash
    bundle install
    ```

2.  **Configuração do Banco de Dados:**
    Execute o comando para criar o banco e rodar as migrações:
    ```bash
    rails db:setup
    ```

---

## ⚠️ Configuração do Usuário Administrador

Para acessar o sistema como administrador, você deve verificar se já existe um usuário criado ou criar um manualmente via terminal, conforme os cenários abaixo.

### Passo 1: Acesse o Console do Rails
No terminal, na raiz do projeto, execute:
```bash
rails console
````

### Passo 2: Verifique se já existe um Admin

Dentro do console, execute o comando abaixo para buscar um administrador:

```ruby
admin = Usuario.where(ocupacao: 'admin').first
puts admin ? "Email encontrado: #{admin.email}" : "Nenhum admin encontrado."
```

### Passo 3: Decida o fluxo com base no resultado

#### **Cenário A: Nenhum admin encontrado**

Ainda dentro do console, copie e cole o código abaixo para criar um novo administrador:

```ruby
Usuario.create!(
  nome: "Administrador",
  email: "admin@test.com",
  usuario: "admin",
  matricula: "000000",
  password: "password123",
  password_confirmation: "password123",
  ocupacao: :admin,
  status: true
)
```

*Agora você pode logar com o email `admin@test.com` e a senha `password123`.*

#### **Cenário B: Admin encontrado (Recuperação de Senha)**

Se o console retornou um usuário (ex: `admin@test.com`) mas você não sabe a senha:

1.  Copie o e-mail retornado no console.
2.  Saia do console (digite `exit`).
3.  Inicie o servidor (veja a seção "Rodando a Aplicação" abaixo).
4.  Acesse a tela de login no navegador.
5.  Clique em **"Esqueci minha senha"**.
6.  Insira o e-mail do administrador.
7.  O sistema utiliza a gem `letter_opener`. Uma nova aba abrirá automaticamente no seu navegador contendo o e-mail simulado com o link de redefinição.
8.  Clique no link, defina uma nova senha e faça o login.

-----

## Rodando a Aplicação

Para iniciar o servidor web:

```bash
rails s
```

Acesse a aplicação em: [http://localhost:3000](https://www.google.com/search?q=http://localhost:3000)

## Rodando os Testes

O projeto conta com testes unitários (RSpec) e de aceitação (Cucumber).

  * **RSpec:**

    ```bash
    bundle exec rspec
    ```

  * **Cucumber:**

    ```bash
    bundle exec cucumber
    ```

  * **Verificar Qualidade (RubyCritic):**

    ```bash
    bundle exec rubycritic
    ```
