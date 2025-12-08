Rails.application.routes.draw do
  # ============================
  # Autenticação
  # ============================
  get    "/login",  to: "autenticacao#new"
  post   "/login",  to: "autenticacao#create"
  delete "/logout", to: "autenticacao#destroy"

  # ============================
  # Admin
  # ============================
  get  "/admin", to: "admin#index", as: :admin
  get  "/admin/gerenciamento", to: "admin#gerenciamento", as: :admin_gerenciamento
  post "/admin/gerenciamento/importar_dados", to: "admin#importar_dados", as: :importar_dados

  # ============================
  # Usuários
  # ============================
  resources :usuarios
  post "/redefinir_senha", to: "usuarios#redefinir_senha"

  # ============================
  # Home
  # ============================
  get  "/home", to: "home#index"
  root "home#index"

  # ============================
  # Templates
  # ============================
  resources :templates do
    resources :template_questions, only: [:create, :update, :destroy] do
      post "add_alternative", on: :member
    end
  end

  namespace :admin do
    resources :formularios, only: [:index, :create]
  end
  resources :avaliacoes, only: [:index]
  root "home#index"
  # ============================
  # Health Check
  # ============================
  get "/up", to: "rails/health#show", as: :rails_health_check
end
