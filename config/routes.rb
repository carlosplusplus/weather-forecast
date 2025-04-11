Rails.application.routes.draw do
  root "forecasts#index"
  get "forecasts/search", to: "forecasts#search", as: "search_forecasts"
end
