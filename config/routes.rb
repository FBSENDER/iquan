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

  get "/detail/x_:id", to: "diyquan#detail_x"
  get "/detail/y_:id", to: "diyquan#detail_y"
  get "/detail/z_:id", to: "diyquan#detail_z"

  get "/youhui/:id", to: "diyquan#get_coupon_by_id", id: /\d+/
  get "/zhuanchang/:id", to: "diyquan#zhuanchang", id: /\d+/
  get "/fenlei/:pinyin", to: "diyquan#fenlei"
  get "/zhekou/:keyword/", to: "diyquan#zhekou"
  get "/zhekou/:keyword/rexiao/", to: "diyquan#zhekou_rexiao"
  get "/zhekou/:keyword/tejia/", to: "diyquan#zhekou_tejia"
  get "/zhekou/:keyword/dae/", to: "diyquan#zhekou_dae"
  get "/zhekou/:keyword/yizhe/", to: "diyquan#zhekou_yizhe"
  get "/zhekou/:keyword/platform2/", to: "diyquan#zhekou_jd"
  get "/zhekou/:keyword/platform3/", to: "diyquan#zhekou_pdd"
  get "/lanlan_download/", to: "diyquan#lanlan_download"
  get "/query/noresult", to: "diyquan#noresult"
  get "/baokuan/", to: "diyquan#baokuan"
  get "/9kuai9/", to: "diyquan#k9"
  get "/shikuaigou/", to: "diyquan#k20"
  get "/article/:id.html", to: "diyquan#article"

  get "/dianpu/", to: "dianpu#map_s"
  get "/dianpu/:nick/", to: "dianpu#show"
  get "/dianpu_buy/:seller_id/", to: "dianpu#buy"
  get "/buy/z_:id", to: "diyquan#buy_z"
  get "/buy/y_:id", to: "diyquan#buy_y"
  get "/buy/:id", to: "diyquan#buy"
  get "/buy_url/x_:id", to: "diyquan#buy_url_x"
  get "/buy_url/y_:id", to: "diyquan#buy_url_y"
  get "/buy_url/z_:id", to: "diyquan#buy_url_z"

  #html sitemap
  get "/map_k/", to: "diyquan#map_k"
  get "/map_k/:page", to: "diyquan#map_k"

  #amp
  get "/amp/qq/:keyword", to: "amp#qq"
  get "/amp/map-k-:letter-:page1-:page2.html", to: "amp#map_keyword"
end
