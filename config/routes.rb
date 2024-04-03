Rails.application.routes.draw do
  devise_for :admins, only: []
  devise_for :users, only: []

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      namespace :stripe do
        resource :webhook, only: [:create]
      end

      namespace :razorpay do
        resource :webhook, only: [:create]
      end

      namespace :admin do
        devise_scope :admin do
          post   'sign_in',  to: 'sessions#create'
          delete 'sign_out', to: 'sessions#destroy'
          resource :passwords, only: [:create, :update]
        end
        resource :account, only: [:show, :update] do
          put :password, on: :collection
        end
        resources :admins
        resources :users
        resources :plans
        resources :subscriptions, only: [:index]

        resources :curriculums
        resources :subjects
        resources :topics
        resources :papers
        resources :exams
        resources :questions
        resources :answers
        resources :question_images
        resources :challenges
        resources :challenge_submissions, only: [:index, :show]
        resources :submission_answers, only: [:index]
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
        resource :stripe, only: [] do
          collection do
            get :payment_methods
            post :setup_intent
            put :default_payment_method
            get :customer
          end
        end
        resources :subscriptions, only: [:index, :show, :create, :update] do
          put :cancel, on: :member
        end

        resources :questions, only: [:index, :show]
        resources :daily_challenges, only: [:index, :show]
        resources :challenge_submissions do
          put :submit, on: :member
          post :direct_submit, on: :collection
        end
        resources :submission_answers
        resources :activities
        resources :activity_questions, only: [:index, :create, :destroy]

        resources :saved_user_exams, only: [:index, :create, :destroy]
        resources :user_exams
      end

      namespace :web do
        resources :plans, only: [:index]
        resources :curriculums, only: [:index, :show]
        resources :subjects, only: [:index, :show]
        resources :topics, only: [:index, :show]
        resources :papers, only: [:index, :show]
        resources :exams, only: [:index, :show]
      end
    end
  end
end
