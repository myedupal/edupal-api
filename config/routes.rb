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
        resources :users do
          get :count, on: :collection
        end
        resources :plans
        resources :subscriptions, only: [:index]
        resources :reports, only: [] do
          get :user_current_streaks_count, on: :collection
          get :user_max_streaks_count, on: :collection
          get :user_recent_check_in_count, on: :collection
          get :user_recent_submission_count, on: :collection
          get :submission_recent_count, on: :collection
          get :point_activity_recent_count, on: :collection
        end

        resources :curriculums
        resources :subjects
        resources :topics
        resources :papers
        resources :exams
        resources :questions
        resources :answers
        resources :question_images
        resources :challenges
        resources :submissions, only: [:index, :show]
        resources :submission_answers, only: [:index]
        resources :gift_cards

        resources :guess_words do
          get :export_csv, on: :collection
        end
        resources :guess_word_submissions, only: [:index, :show]
        resources :guess_word_dictionaries do
          post :import, on: :collection
        end
        resources :guess_word_pools do
          post :import, on: :member
        end

        resources :referral_activities, only: [:index, :show] do
          post :nullify, on: :member
          post :revalidate, on: :member
        end
      end

      namespace :user do
        devise_scope :user do
          post '/', to: 'registrations#create'
          post   'sign_in',  to: 'sessions#create'
          delete 'sign_out', to: 'sessions#destroy'
          resource :passwords, only: [:create, :update]
        end
        resource :oauth, controller: :oauth, only: [] do
          post :google, on: :collection
        end
        resource :account, only: [:show, :update] do
          put :password, on: :collection
          get :zklogin_salt, on: :collection
          post :update_referral, on: :collection
        end

        resource :stripe, only: [] do
          collection do
            get :payment_methods
            post :detach_payment_method
            post :setup_intent
            put :default_payment_method
            get :customer
          end
        end
        resources :subscriptions, only: [:index, :show, :create, :update] do
          put :cancel, on: :member
          post :redeem, on: :collection
        end
        resources :quotes, only: [:index, :show, :create, :update] do
          put :accept, on: :member
          get :payment_intent, on: :member
          put :cancel, on: :member
          get :show_pdf, on: :member
        end

        resources :questions, only: [:index, :show]
        resources :daily_challenges, only: [:index, :show]
        resources :submissions do
          put :submit, on: :member
          post :direct_submit, on: :collection
        end
        resources :submission_answers
        resources :activities
        resources :activity_questions, only: [:index, :create, :destroy]

        resources :saved_user_exams, only: [:index, :create, :destroy]
        resources :user_exams
        resources :reports, only: [] do
          get :daily_challenge, on: :collection
          get :mcq, on: :collection
          get :points, on: :collection
          get :guess_word, on: :collection
          get :subject, on: :collection
        end
        resources :point_activities, only: [:index]

        resources :guess_words, only: [:index, :show] do
          resources :guess_word_submissions, only: [:index] do
            post :guess, on: :collection, action: :direct_guess
          end
        end
        resources :guess_word_submissions, only: [:index, :show, :create] do
          post :guess, on: :member
        end
        resources :guess_word_pools do
          post :import, on: :member
          get :daily_guess_word, on: :member
        end

        resources :referral_activities, only: [:index, :show]

        resources :user_collections

        resources :study_goals
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
