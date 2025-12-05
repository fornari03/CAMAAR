Rails.application.routes.draw do
  # Autenticação
  get    "/login",  to: "autenticacao#new"
  post   "/login",  to: "autenticacao#create"
  delete "/logout", to: "autenticacao#destroy"

  # Painel Admin
  get "/admin", to: "admin#index", as: :admin

  # CRUD de usuários
  resources :usuarios

  # Página inicial Home
  get "/home", to: "home#index"

  post "/redefinir_senha" , to: "usuarios#redefinir_senha"


  root "autenticacao#new"
end
