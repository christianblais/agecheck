Rails.application.routes.draw do
  resource :shop, only: [:update]

  controller :callbacks do
    get 'javascript', format: :js
    post 'callback'
  end

  root to: 'home#index'

  mount ShopifyApp::Engine, at: '/'
end
