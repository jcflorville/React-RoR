Rails.application.routes.draw do
  defaults format: :json do
    devise_for :users,
      path: '',
      controllers: {
        sessions: 'api/v1/auth/sessions',
        registrations: 'api/v1/auth/registrations'
      },
      skip: [ :sessions, :registrations ]
    namespace :api do
      namespace :v1 do
         resources :contacts, only: [ :index, :create ]
        namespace :auth do
          # Definir rotas customizadas apenas para API
          devise_scope :user do
            post 'sign_in', to: 'sessions#create'
            delete 'sign_out', to: 'sessions#destroy'
            post 'sign_up', to: 'registrations#create'
          end

          # Refresh token endpoint
          post 'refresh', to: 'refresh#create'
        end

        # Endpoints públicos
        scope module: :public do
          resources :users, only: [ :index, :show ]
        end

        # Endpoints privados
        scope module: :authenticated do
          resource :profiles, only: [ :show, :update ]

          # Nested resources - tasks within projects
          resources :projects do
            resources :tasks, controller: 'projects/tasks' do
              member do
                patch :complete
                patch :reopen
              end
            end
          end

          # Flat resources - for cross-project operations
          resources :tasks do
            collection do
              get :mine # todas as tasks do usuário
              get :overdue # tasks em atraso
            end
            member do
              patch :complete
              patch :reopen
            end
          end

          resources :categories
          resources :comments, except: [ :show ]
          resources :drawings

          # Notifications
          resources :notifications, only: [ :index, :show, :destroy ] do
            collection do
              get :unread_count
              post :mark_all_as_read
            end
            member do
              patch :mark_as_read
              patch :mark_as_unread
            end
          end

          # Notification Stream (SSE)
          get 'notification_stream', to: 'notification_stream#index'

          # Webhook Subscriptions
          resources :webhook_subscriptions do
            member do
              post :enable
              post :disable
            end
          end
        end
      end
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check
end
