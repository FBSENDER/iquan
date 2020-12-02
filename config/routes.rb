Rails.application.routes.draw do
  root "home#index"
  get "/index.html", to: "home#frame_home"  
  get "/zhekou/:keyword/", to: "diyquan#zhekou"
  get "/g_:pinyin/", to: "diyquan#page"

  # Ying
  #get "/peishi", to: "ying#peishi"
  #get "/peishi/:id", to: "ying#peishi_product", id: /\d+/
  #get "/meizhuang", to: "ying#meizhuang"
  #get "/meizhuang/:id", to: "ying#meizhuang_product", id: /\d+/

  get "/query/noresult", to: "diyquan#noresult"
  get "/dianpu/", to: "dianpu#map_s"
  get "/dianpu/jd_:id", to: "dianpu#jd_show", id: /\d+/
  get "/dianpu/:nick/", to: "dianpu#show"


  #html sitemap
  get "/map_k/", to: "diyquan#map_k"
  get "/map_k/:page", to: "diyquan#map_k"

  #ddk
  get "/ddk/:id", to: "ddk#product_detail", id: /\d+/
  get "/ddkyh/:keyword/", to: "ddk#youhui", keyword: /.+/
  get "/ddkcate/:cid", to: "ddk#category", cid: /\d+/
  get "/ddkrec/:type", to: "ddk#rec", id: /\d+/

  #amp
  get "/amp/zhekou/:keyword/", to: "amp#zhekou"
  get "/amp/g_:pinyin/", to: "amp#page"

  #kefu
  #post "kefu/bd_post_message", to: "kefu#check_post_message"
  post "kefu/bd_post_message", to: "kefu#receive_message"

end
