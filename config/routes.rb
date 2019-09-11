Rails.application.routes.draw do
  root "home#index"
  get "/saber/detail", to: "home#index"
  get "/saber/search", to: "home#index"
  get "/saber/index", to: "home#index"

  get "/getHomeCouponList", to: "diyquan#get_coupons_index"
  get "/getFenleiCouponList", to: "diyquan#get_coupons_fenlei"
  get "/getSearchCouponList", to: "diyquan#get_coupons_search"
  get "/getHotCouponList", to: "diyquan#get_coupons_hot"
  get "/getK9CouponList", to: "diyquan#get_coupons_k9"
  get "/getK20CouponList", to: "diyquan#get_coupons_k20"

  get "/getLanlanHomeCouponList", to: "diyquan#get_lanlan_coupons_index"
  get "/getLanlanFenleiCouponList", to: "diyquan#get_lanlan_coupons_fenlei"
  get "/getLanlanSearchCouponList", to: "diyquan#get_lanlan_coupons_search"

  get "/youhui/:id", to: "diyquan#get_coupon_by_id", id: /\d+/
  get "/zhuanchang/:id", to: "diyquan#zhuanchang", id: /\d+/
  get "/fenlei/:pinyin", to: "diyquan#fenlei"
  get "/zhekou/:keyword/", to: "diyquan#zhekou"
  get "/zhekou/:keyword/rexiao/", to: "diyquan#zhekou_rexiao"
  get "/zhekou/:keyword/tejia/", to: "diyquan#zhekou_tejia"
  get "/zhekou/:keyword/dae/", to: "diyquan#zhekou_dae"
  get "/zhekou/:keyword/yizhe/", to: "diyquan#zhekou_yizhe"
  get "/lanlan_download/", to: "diyquan#lanlan_download"
  get "/query/noresult", to: "diyquan#noresult"
  get "/baokuan/", to: "diyquan#baokuan"
  get "/9kuai9/", to: "diyquan#k9"
  get "/shikuaigou/", to: "diyquan#k20"
  get "/article/:id.html", to: "diyquan#article"

  get "/dianpu/", to: "dianpu#map_s"
  get "/dianpu/:nick/", to: "dianpu#show"
  get "/dianpu_buy/:seller_id/", to: "dianpu#buy"
  get "/buy/:id", to: "diyquan#buy"

  #html sitemap
  get "/map_k/", to: "diyquan#map_k"
  get "/map_k/:page", to: "diyquan#map_k"

  #amp
  get "/amp/qq/:keyword", to: "amp#qq"
end
