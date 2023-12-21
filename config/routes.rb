Rails.application.routes.draw do
  devise_for :admins, only: []
  devise_for :users, only: []

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      namespace :admin do
        devise_scope :admin do
          post   'sign_in',  to: 'sessions#create'
          delete 'sign_out', to: 'sessions#destroy'
          resource :passwords, only: [:create, :update]
        end
        resource :account, only: [:show, :update] do
          put :password, on: :collection
        end
      end

      namespace :user do
        devise_scope :user do
          post '/', to: 'registrations#create'
          post   'sign_in',  to: 'sessions#create'
          delete 'sign_out', to: 'sessions#destroy'
          resource :passwords, only: [:create, :update]
        end
        resource :account, only: [:show, :update] do
          put :password, on: :collection
        end
      end
    end
  end
end
