Rails.application.routes.draw do
  resources :games do
    post 'take_card', on: :member
    post 'take_multiple_cards', on: :member
    post 'hand_to_market', on: :member
    post 'trade_in_tokens', on: :member
    # post 'end_turn', on: :member
    post 'take_all_camels', on: :member
    post 'multiple_cards_to_market', on: :member
  end
    # get 'games/hand', to: 'games#hand'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "games#index"
end
