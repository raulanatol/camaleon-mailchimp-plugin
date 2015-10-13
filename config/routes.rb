Rails.application.routes.draw do

  scope '(:locale)', locale: /#{PluginRoutes.all_locales}/, :defaults => {} do
    # frontend
    namespace :plugins do
      namespace 'camaleon_mailchimp' do
        get 'index' => 'front#index'
        post 'hooks' => 'front#hook'
      end
    end
  end

  #Admin Panel
  scope 'admin', as: 'admin' do
    namespace 'plugins' do
      namespace 'camaleon_mailchimp' do
        get 'settings' => 'admin#settings'
        post 'settings' => 'admin#save_settings'

        patch ':user_id/subscribe' => 'admin#subscribe', :as => 'subscribe'
        patch ':user_id/unsubscribe' => 'admin#unsubscribe', :as => 'unsubscribe'
      end
    end
  end

  # main routes
  #scope 'camaleon_mailchimp', module: 'plugins/camaleon_mailchimp/', as: 'camaleon_mailchimp' do
  #  Here my routes for main routes
  #end
end
