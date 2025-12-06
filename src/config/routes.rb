Rails.application.routes.draw do
  get "gerenciamento" => "admin#gerenciamento", as: :admin_gerenciamento
  
  get "up" => "rails/health#show", as: :rails_health_check

  post '/gerenciamento/importar_dados', to: 'admin#importar_dados', as: 'importar_dados'

end