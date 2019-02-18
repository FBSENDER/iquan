class DianpuController < ApplicationController
  def show
    if is_robot?
      return if redirect_pc_to_mobile
    else
      if request.host != 'tt.uuhaodian.com'
        redirect_to "http://tt.uuhaodian.com#{request.path}/", status: 302
        return
      end
    end
    @shop = Shop.where(nick: params[:nick]).select(:id, :title, :nick, :provcity, :shop_url, :pic_url, :dsr_info, :is_tmall, :totalsold, :procnt, :main_auction, :search_keyword).take
    not_found if @shop.nil?
    @taodianjin_pid = is_device_mobile? ? $taodianjin_mobile_pid : $taodianjin_pc_pid
    @dsr_info = JSON.parse(@shop.dsr_info)
    ind = JSON.parse(@dsr_info["dsrStr"])["ind"]
    @desc = "#{@shop.title}是一家经营信誉良好、获得消费者广泛好评的一家#{@shop.is_tmall == 1 ? '天猫' : '淘宝'}店铺。店铺掌柜为#{@shop.nick}，如果大家有任何关于#{@shop.title}的问题，都可以向其进行咨询。店铺的注册地点在#{@shop.provcity}，全国包邮哦，看到合适的宝贝赶快拍下，#{@shop.provcity}附近的朋友们可能在当天就收到快递喽。#{@shop.title}在售的宝贝有#{@shop.totalsold}件，有木有很多！近30天的销量为#{@shop.procnt}件，代掌柜#{@shop.nick}感谢大家的大力支持。#{@shop.title}主营类目为#{ind}，具体有#{@shop.main_auction}，欢迎大家选购。#{@shop.title}的综合评分还是不错的，在宝贝描述相符、服务态度、物流服务上均在平均水平之上，大家可以放心选购自己心仪的宝贝。
还在等什么？快去#{@shop.title}逛一逛~"
    @items = []
    @hot_coupons = []
    @coupons = []
    @suggest_keywords = []
    @path = "#{request.path}/"
    @shops = Shop.where("id > ?", @shop.id).order("id").select(:nick,:pic_url,:title).limit(15)
    @scoupons = []
    @big_keywords = $big_keywords
    @zhekous = []
    data  = get_tbk_search_json(@shop.search_keyword, 1)
    if(data["tbk_item_get_response"] && data["tbk_item_get_response"]["total_results"] > 0)
      @zhekous = data["tbk_item_get_response"]["results"]["n_tbk_item"]
    end
    if is_device_mobile?
      render "m_show", layout: "m_diyquan"
    else
      render "show", layout: "diyquan"
    end
  end

  def buy
    redirect_to "https://market.m.taobao.com/apps/aliyx/coupon/detail.html?wh_weex=true&activity_id=#{params[:activity_id]}&seller_id=#{params[:seller_id]}", status: 302
  end

  def map_s
    @page = params[:page].to_i
    @page = @page == 0 ? 0 : @page - 1
    @shops = Shop.order("id desc").limit(1000).offset(1000 * @page).select(:title, :nick).to_a
    not_found if @shops.size.zero?
    if @page > 0
      @title = "淘宝天猫旗舰店排行榜-女装男装居家数码美妆箱包_十块购_第#{@page}页"
    else
      @title = "淘宝天猫旗舰店排行榜-女装男装居家数码美妆箱包_十块购"
    end
    @total_page = @page + 20
    @h1 = "淘宝天猫旗舰店排行榜"
    @keywords = "天猫旗舰店,淘宝店铺,淘宝店铺大全,淘宝店铺排行榜"
    @description = "淘宝天猫旗舰店排行榜，女装、男装、居家、数码、美妆、箱包、母婴、宠物、配饰等多种类别的淘宝天猫店铺大排行，淘宝天猫店铺用户评价，卖的商品怎么样？店铺打折信息，内部优惠券，这里都查得到 - 十块购"
    @path = "/dianpu/"
    render "map_s", layout: "diyquan"
  end

  def get_tbk_search_json(keyword, page_no)
    tbk = Tbkapi::Taobaoke.new
    JSON.parse(tbk.taobao_tbk_item_get(keyword, $taobao_app_id, $taobao_app_secret, page_no + 1,50))
  end
end
