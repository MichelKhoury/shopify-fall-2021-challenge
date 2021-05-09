Rails.application.routes.draw do
  get "/images/imageSearch", to: "images#image_search", as: "image_search"
  post "/images/findImages", to: "images#find_images", as: "find_images"
  get "/images/tagSearch", to: "images#tag_search", as: "tag_search"
  resources :images
  # get 'home/index'
  root "home#index"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
