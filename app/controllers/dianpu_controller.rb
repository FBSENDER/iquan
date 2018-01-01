class DianpuController < ApplicationController
  def show
    @shop = Shop.where(nick: params[:nick]).take
    not_found if @shop.nil?
    @dsr_info = JSON.parse(@shop.dsr_info)
    ind = JSON.parse(@dsr_info["dsrStr"])["ind"]
    @desc = "#{@shop.title}是一家经营信誉良好、获得消费者广泛好评的一家#{@shop.is_tmall == 1 ? '天猫' : '淘宝'}店铺。店铺掌柜为#{@shop.nick}，如果大家有任何关于#{@shop.title}的问题，都可以向其进行咨询。店铺的注册地点在#{@shop.provcity}，全国包邮哦，看到合适的宝贝赶快拍下，#{@shop.provcity}附近的朋友们可能在当天就收到快递喽。#{@shop.title}在售的宝贝有#{@shop.totalsold}件，有木有很多！近30天的销量为#{@shop.procnt}件，代掌柜#{@shop.nick}感谢大家的大力支持。#{@shop.title}主营类目为#{ind}，具体有#{@shop.main_auction}，欢迎大家选购。#{@shop.title}的综合评分还是不错的，在宝贝描述相符、服务态度、物流服务上均在平均水平之上，大家可以放心选购自己心仪的宝贝。
还在等什么？快去#{@shop.title}逛一逛~"
    @items = JSON.parse(@shop.auctions_inshop)
    #@hot_coupons = get_hot_coupons(0, 0, 20)
    @hot_coupons = []
    @suggest_keywords = get_suggest_keywords_new(@shop.search_keyword)
    @path = "#{request.path}/"
    @shops = Shop.where("id > ?", @shop.id).order("id").select(:nick,:pic_url,:title).limit(15)
    @scoupons = ShopCoupon.where(seller_id: @shop.source_id).to_a
    render "show", layout: "diyquan"
  end

  def buy
    redirect_to "https://market.m.taobao.com/apps/aliyx/coupon/detail.html?wh_weex=true&activity_id=#{params[:activity_id]}&seller_id=#{params[:seller_id]}", status: 302
  end

  def map_s
    @shops = Shop.select(:title, :nick).to_a
    @title = "淘宝天猫旗舰店排行榜_爱券网"
    @h1 = "淘宝天猫旗舰店排行榜"
    @keywords = "天猫旗舰店,淘宝店铺,淘宝店铺大全,淘宝店铺排行榜"
    @description = "淘宝天猫旗舰店排行榜，女装、男装、居家、数码、美妆、箱包、母婴、宠物、配饰等多种类别的淘宝天猫店铺大排行，淘宝天猫店铺用户评价，卖的商品怎么样？店铺打折信息，内部优惠券，这里都查得到 - 爱券网"
    @path = "/dianpu/"
    render "map_s", layout: "diyquan"
  end
end
