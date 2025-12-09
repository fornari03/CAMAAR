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

  get "admin/gerenciamento" => "admin#gerenciamento", as: :admin_gerenciamento
  
  get "up" => "rails/health#show", as: :rails_health_check

  post 'admin/gerenciamento/importar_dados', to: 'admin#importar_dados', as: 'importar_dados'

  resources :templates do
    resources :template_questions, only: [:create, :update, :destroy] do
      post 'add_alternative', on: :member
    end
  end

  namespace :admin do
    resources :formularios, only: [:index, :create]
  end
  resources :avaliacoes, only: [:index]
  root "home#index"
end
