Rails.application.routes.draw do
  root "home#index"
  get "/test/", to: "test#index"
  get "/test/child", to: "test#child"
  get "/article/", to: "article#index"
  get "/article/:id", to: "article#show"
  get "/article/:id/update", to: "article#update"
  post "/article/publish", to: "article#publish"
  get "/tag/", to: "article#tag_index"
  get "/tag/:name", to: "article#tag"
  post "/search/", to: "search#do_search"
  post "/search/app", to: "search#app_search"
  get "/search/", to: "search#no_result"
  get "/shishen/", to: "card#index"
  get "/shishen/:id", to: "card#show"

  #app
  get "/app/card/:id", to: "app#card"
  get "/app/card_ssr", to: "app#card_ssr"
  get "/app/card_sr", to: "app#card_sr"
  get "/app/card_r", to: "app#card_r"

  get "/app/article_gonglve", to: "app#article_gonglve"
  get "/app/article_news", to: "app#article_news"
  get "/app/article_wenda", to: "app#article_wenda"
  get "/app/article/:id", to: "app#article", id: /\d+/
  get "/app/tag/:name", to: "app#tag"

  get "/app/jubao", to: "app#jubao"
  get "/app/hot", to: "app#hot"
end
