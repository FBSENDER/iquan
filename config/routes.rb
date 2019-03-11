Rails.application.routes.draw do
  root "home#index"
  get "/index.html", to: "home#frame_home"  

  get "/youhui/:id", to: "diyquan#get_coupon_by_id", id: /\d+/
  get "/fenlei/:pinyin", to: "diyquan#fenlei"
  get "/tbzk/", to: "diyquan#zhekou"
  get "/zhekou/:keyword/", to: "diyquan#zhekou"
  get "/zhekou/:keyword/rexiao/", to: "diyquan#zhekou_rexiao"
  get "/zhekou/:keyword/tejia/", to: "diyquan#zhekou_tejia"
  get "/zhekou/:keyword/dae/", to: "diyquan#zhekou_dae"
  get "/zhekou/:keyword/yizhe/", to: "diyquan#zhekou_yizhe"
  get "/lanlan_download/", to: "diyquan#lanlan_download"
  get "/g_:pinyin/", to: "diyquan#page"
  get "/k_:pinyin/", to: "diyquan#k_pinyin"
  get "/category/:cid", to: "diyquan#lanlan_fenlei"

  get "/query/noresult", to: "diyquan#noresult"
  get "/dianpu/", to: "dianpu#map_s"
  get "/dianpu/:nick/", to: "dianpu#show"
  get "/dianpu_buy/:seller_id/", to: "dianpu#buy"

  #html sitemap
  get "/map_k/", to: "diyquan#map_k"
  get "/map_k/:page", to: "diyquan#map_k"

  #ddk
  get "/ddk/:id", to: "ddk#product_detail", id: /\d+/
  get "/ddkyh/:keyword/", to: "ddk#youhui", keyword: /.+/
  get "/ddkcate/:cid", to: "ddk#category", cid: /\d+/

end
