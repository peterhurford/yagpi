Rails.application.routes.draw do
  root 'pages#index'
  mount Gitpiv::API => '/api'
end
