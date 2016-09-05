Rails.application.routes.draw do
  constraints id: /[^\/]+/ do
    resources :domains do
      resources :assets, controller: 'domains/assets' do
      end
    end
  end
end
