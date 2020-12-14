class DianpuController < ApplicationController
  def jd_show
    return if redirect_pc_to_mobile
    s = JdShop.where(shop_id: params[:id].to_i).select(:id, :content, :img_url).take
    not_found if s.nil?
    c = JSON.parse(s.content)
    d = c["result"]
    @shop_id = d["shop_id"]
    @shop_name = d["shop_name"]
    @img_url = s.img_url.nil? || s.img_url.empty? ? "/image/love.jpg" : s.img_url
    @coupons = d["coupons"]
    @products = d["products"]
    @brands = d["brands"]
    @cid3s = d["cid3s"]
    @related = d["related"] || []
    @more = d["more"] || []
    @desc = "#{@shop_name}是一家经营信誉良好、获得消费者广泛好评的一家京东店铺。#{@shop_name}主要经营：#{@cid3s.map{|c| c["cname3"]}.join('，')}。店内正在销售#{@brands.map{|b| b["brand_name"]}.join('，')}品牌商品。近日店铺有优惠券发放，欢迎大家关注！#{@coupons.map{|c| "满#{c["quota"]}元减#{c["discount"]}元"}.join('、')} 热销商品有：#{@products.sample(3).map{|r| r["title"]}.join('，')} 喜欢的话常来店铺逛逛呀！"
    @path = "#{request.path}/"
    @suggest_keywords = @cid3s.map{|c| c["cname3"]} + @brands.map{|b| b["brand_name"]}

    url = "https://mall.jd.com/index-#{@shop_id}.html"
    if is_device_mobile?
      url = "https://shop.m.jd.com/?shopId=#{@shop_id}"
    end
    @hurl = "http://www.uuhaodian.com/jddiybuy?jd_channel=18&url=#{URI.encode_www_form_component(url)}"

    render "jd_show", layout: "diyquan"
  end

  def m_jd_show
    s = JdShop.where(shop_id: params[:id].to_i).select(:id, :content, :img_url).take
    not_found if s.nil?
    c = JSON.parse(s.content)
    d = c["result"]
    @shop_id = d["shop_id"]
    @shop_name = d["shop_name"]
    @img_url = s.img_url.nil? || s.img_url.empty? ? "/image/love.jpg" : s.img_url
    @coupons = d["coupons"]
    @products = d["products"]
    @brands = d["brands"]
    @cid3s = d["cid3s"]
    @related = d["related"] || []
    @more = d["more"] || []
    @desc = "#{@shop_name}是一家经营信誉良好、获得消费者广泛好评的一家京东店铺。#{@shop_name}主要经营：#{@cid3s.map{|c| c["cname3"]}.join('，')}。店内正在销售#{@brands.map{|b| b["brand_name"]}.join('，')}品牌商品。近日店铺有优惠券发放，欢迎大家关注！#{@coupons.map{|c| "满#{c["quota"]}元减#{c["discount"]}元"}.join('、')} 热销商品有：#{@products.sample(3).map{|r| r["title"]}.join('，')} 喜欢的话常来店铺逛逛呀！"
    @path = "#{request.path}/"
    @suggest_keywords = @cid3s.map{|c| c["cname3"]} + @brands.map{|b| b["brand_name"]}

    url = "https://mall.jd.com/index-#{@shop_id}.html"
    if is_device_mobile?
      url = "https://shop.m.jd.com/?shopId=#{@shop_id}"
    end
    @hurl = "http://www.uuhaodian.com/jddiybuy?jd_channel=18&url=#{URI.encode_www_form_component(url)}"

    render "m_jd_show", layout: "m_diyquan"
  end

  def show
    return if redirect_pc_to_mobile
    @shop = Shop.where(nick: params[:nick]).take
    not_found if @shop.nil?
    @dsr_info = JSON.parse(@shop.dsr_info)
    ind = JSON.parse(@dsr_info["dsrStr"])["ind"]
    @desc = "#{@shop.title}是一家经营信誉良好、获得消费者广泛好评的一家#{@shop.is_tmall == 1 ? '天猫' : '淘宝'}店铺。店铺掌柜为#{@shop.nick}，如果大家有任何关于#{@shop.title}的问题，都可以向其进行咨询。店铺的注册地点在#{@shop.provcity}，全国包邮哦，看到合适的宝贝赶快拍下，#{@shop.provcity}附近的朋友们可能在当天就收到快递喽。#{@shop.title}在售的宝贝有#{@shop.totalsold}件，有木有很多！近30天的销量为#{@shop.procnt}件，代掌柜#{@shop.nick}感谢大家的大力支持。#{@shop.title}主营类目为#{ind}，具体有#{@shop.main_auction.gsub(/\d/, "")}，欢迎大家选购。#{@shop.title}的综合评分还是不错的，在宝贝描述相符、服务态度、物流服务上均在平均水平之上，大家可以放心选购自己心仪的宝贝。
还在等什么？快去#{@shop.title}逛一逛~"
    @items = JSON.parse(@shop.auctions_inshop.empty? || @shop.auctions_inshop == 'null' ? "[]" : @shop.auctions_inshop)
    #@hot_coupons = get_hot_coupons(0, 0, 20)
    #@hot_coupons = []
    @hot_coupons = []
    @coupons = []
    @suggest_keywords = []
    @path = "#{request.path}/"
    @shops = Shop.where("id > ?", @shop.id).order("id").select(:nick,:pic_url,:title).limit(15)
    @jd_shops = JdShop.where("id > ? and status = 1", @shop.id / 20).select(:shop_id, :shop_name).limit(15)
    @scoupons = []
    render "show", layout: "diyquan"
  end

  def m_show
    return if redirect_pc_to_mobile
    @shop = Shop.where(nick: params[:nick]).take
    not_found if @shop.nil?
    @keyword = @shop.title.gsub("折扣", "").gsub("店铺", "").gsub("品牌", "").gsub("旗舰","").gsub("店", "").gsub("官方", "").gsub("专卖", "").gsub("专营", "")
    @channel = 8
    @dsr_info = JSON.parse(@shop.dsr_info)
    ind = JSON.parse(@dsr_info["dsrStr"])["ind"]
    @desc = "#{@shop.title}是一家经营信誉良好、获得消费者广泛好评的一家#{@shop.is_tmall == 1 ? '天猫' : '淘宝'}店铺。店铺掌柜为#{@shop.nick}，如果大家有任何关于#{@shop.title}的问题，都可以向其进行咨询。店铺的注册地点在#{@shop.provcity}，全国包邮哦，看到合适的宝贝赶快拍下，#{@shop.provcity}附近的朋友们可能在当天就收到快递喽。#{@shop.title}在售的宝贝有#{@shop.totalsold}件，有木有很多！近30天的销量为#{@shop.procnt}件，代掌柜#{@shop.nick}感谢大家的大力支持。#{@shop.title}主营类目为#{ind}，具体有#{@shop.main_auction.gsub(/\d/, "")}，欢迎大家选购。#{@shop.title}的综合评分还是不错的，在宝贝描述相符、服务态度、物流服务上均在平均水平之上，大家可以放心选购自己心仪的宝贝。
还在等什么？快去#{@shop.title}逛一逛~"
    @path = "#{request.path}/"
    render "m_show", layout: "m_diyquan"
  end

  def map_s
    @page = params[:page].to_i
    @page = @page == 0 ? 0 : @page - 1
    @shops = JdShop.where(status: 1).limit(100).offset(100 * @page).select(:id, :shop_id, :shop_name).to_a
    not_found if @shops.size.zero?
    if @page > 0
      @title = "淘宝天猫京东旗舰店排行榜_爱券网_第#{@page}页"
    else
      @title = "淘宝天猫京东旗舰店排行榜_爱券网"
    end
    @total_page = @page + 10 > 548 ? 548 : @page + 10
    @h1 = "淘宝天猫京东旗舰店排行榜"
    @keywords = "京东旗舰店,天猫旗舰店,淘宝店铺,淘宝店铺大全,淘宝店铺排行榜"
    @description = "淘宝天猫京东旗舰店排行榜，女装、男装、居家、数码、美妆、箱包、母婴、宠物、配饰等多种类别的淘宝天猫店铺大排行，淘宝天猫店铺用户评价，卖的商品怎么样？店铺打折信息，内部优惠券，这里都查得到 - 爱券网"
    @path = "/dianpu/"
    render "map_s", layout: "diyquan"
  end
end
