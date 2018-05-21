Rails.application.routes.draw do
  root "home#index"
  get "/saber/detail", to: "home#index"
  get "/saber/search", to: "home#index"
  get "/saber/index", to: "home#index"

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

  #diyquan
  post "/refreshCookies", to: "diyquan#refresh_cookies"
  get "/refreshTbkus", to: "diyquan#refresh_tbkus"
  get "/getOperElements", to: "diyquan#get_categories"

  get "/getHomeCouponList", to: "diyquan#get_coupons_index"
  get "/getFenleiCouponList", to: "diyquan#get_coupons_fenlei"
  get "/getSearchCouponList", to: "diyquan#get_coupons_search"
  get "/getHotCouponList", to: "diyquan#get_coupons_hot"
  get "/getK9CouponList", to: "diyquan#get_coupons_k9"
  get "/getK20CouponList", to: "diyquan#get_coupons_k20"

  get "/getLanlanHomeCouponList", to: "diyquan#get_lanlan_coupons_index"
  get "/getLanlanFenleiCouponList", to: "diyquan#get_lanlan_coupons_fenlei"
  get "/getLanlanSearchCouponList", to: "diyquan#get_lanlan_coupons_search"
  get "/getLanlanTypeCouponList", to: "diyquan#get_lanlan_coupons_type"

  get "/youhui/:id", to: "diyquan#get_coupon_by_id", id: /\d+/
  get "/yh/:id", to: "diyquan#lanlan_detail_page", id: /\d+/
  get "/zk/:id", to: "diyquan#old_zk", id: /\d+/
  get "/buy/:id", to: "diyquan#buy", id: /\d+/
  get "/zhuanchang/:id", to: "diyquan#zhuanchang", id: /\d+/
  get "/fenlei/:pinyin", to: "diyquan#fenlei"
  get "/tbzk/", to: "diyquan#zhekou"
  get "/zhekou/:keyword/", to: "diyquan#zhekou"
  get "/zhekou/:keyword/rexiao/", to: "diyquan#zhekou_rexiao"
  get "/zhekou/:keyword/tejia/", to: "diyquan#zhekou_tejia"
  get "/zhekou/:keyword/dae/", to: "diyquan#zhekou_dae"
  get "/zhekou/:keyword/yizhe/", to: "diyquan#zhekou_yizhe"
  get "/query/", to: "diyquan#search"
  get "/quick_query/", to: "diyquan#quick_search"
  get "/quick_query_title/", to: "diyquan#quick_search_title"
  get "/lanlan_download/", to: "diyquan#lanlan_download"
  get "/g_:pinyin/", to: "diyquan#page"
  get "/k_:pinyin/", to: "diyquan#k_pinyin"
  get "/category/:cid", to: "diyquan#lanlan_fenlei"
  #sem duoshou
  get "/ds/", to: "diyquan#duoshou"

  get "/query/noresult", to: "diyquan#noresult"
  get "/baokuan/", to: "diyquan#baokuan"
  get "/9kuai9/", to: "diyquan#k9"
  get "/shikuaigou/", to: "diyquan#k20"

  get "/dianpu/", to: "dianpu#map_s"
  get "/dianpu/:nick/", to: "dianpu#show"
  get "/dianpu_buy/:seller_id/", to: "dianpu#buy"

  #html sitemap
  get "/map_k/", to: "diyquan#map_k"
  get "/map_k/:page", to: "diyquan#map_k"
end
