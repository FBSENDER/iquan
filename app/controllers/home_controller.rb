class HomeController < ApplicationController
  @@compete_brands = nil
  @@product_brands = nil
  $c1,$c2,$c3,$c4,$c5 = [],[],[],[],[]
  $cc1,$cc2,$cc3,$cc4,$cc5 = [],[],[],[],[]

  def iquan_pc
    if is_device_mobile?
      redirect_to "http://m.iquan.net", status: 302
      return
    end
    if @@compete_brands.nil? || Time.now.to_i % 600 == 0
      @@compete_brands = CompeteBrand.select(:title, :keywords, :description, :host).to_a
    end
    #file = Rails.root.join("public/seo_articles").join("iquan_pc_home.html")
    #if File.exists?(file) && !params[:is_refresh]
    #  render inline: File.read(file), layout: nil
    #  return
    #end
    @compete_brands = @@compete_brands.sample(10)
    diyquan_home
  end

  def iquan_mobile
    if @@compete_brands.nil? || Time.now.to_i % 600 == 0
      @@compete_brands = CompeteBrand.select(:title, :keywords, :description, :host).to_a
    end
    @compete_brands = @@compete_brands.sample(10)
    m_diyquan_home
  end

  def index
    @pc_host = request.host
    if request.host == "www.guanew.net" || request.host == 'm.guanew.net'
      if $cc1.size.zero?
        data  = get_tbk_search_json("男牛仔裤", 0)
        if(data["tbk_item_get_response"] && data["tbk_item_get_response"]["total_results"] > 0)
          $cc1 = data["tbk_item_get_response"]["results"]["n_tbk_item"]
        end
      end
      if $cc2.size.zero?
        data  = get_tbk_search_json("女牛仔裤", 0)
        if(data["tbk_item_get_response"] && data["tbk_item_get_response"]["total_results"] > 0)
          $cc2 = data["tbk_item_get_response"]["results"]["n_tbk_item"]
        end
      end
      if $cc3.size.zero?
        data  = get_tbk_search_json("李维斯牛仔裤", 0)
        if(data["tbk_item_get_response"] && data["tbk_item_get_response"]["total_results"] > 0)
          $cc3 = data["tbk_item_get_response"]["results"]["n_tbk_item"]
        end
      end
      if $cc4.size.zero?
        data  = get_tbk_search_json("lee牛仔裤", 0)
        if(data["tbk_item_get_response"] && data["tbk_item_get_response"]["total_results"] > 0)
          $cc4 = data["tbk_item_get_response"]["results"]["n_tbk_item"]
        end
      end
      if $cc5.size.zero?
        data  = get_tbk_search_json("ck牛仔裤", 0)
        if(data["tbk_item_get_response"] && data["tbk_item_get_response"]["total_results"] > 0)
          $cc5 = data["tbk_item_get_response"]["results"]["n_tbk_item"]
        end
      end
      @c1 = $cc1
      @c2 = $cc2
      @c3 = $cc3
      @c4 = $cc4
      @c5 = $cc5
      render 'niuzaiku', layout: 'lingshi'
      return
    end
    if request.host == "www.flowlover.com" || request.host == 'm.flowlover.com'
      if $c1.size.zero?
        data  = get_tbk_search_json("猪肉脯", 0)
        if(data["tbk_item_get_response"] && data["tbk_item_get_response"]["total_results"] > 0)
          $c1 = data["tbk_item_get_response"]["results"]["n_tbk_item"]
        end
      end
      if $c2.size.zero?
        data  = get_tbk_search_json("面包干", 0)
        if(data["tbk_item_get_response"] && data["tbk_item_get_response"]["total_results"] > 0)
          $c2 = data["tbk_item_get_response"]["results"]["n_tbk_item"]
        end
      end
      if $c3.size.zero?
        data  = get_tbk_search_json("猕猴桃干", 0)
        if(data["tbk_item_get_response"] && data["tbk_item_get_response"]["total_results"] > 0)
          $c3 = data["tbk_item_get_response"]["results"]["n_tbk_item"]
        end
      end
      if $c4.size.zero?
        data  = get_tbk_search_json("丸太拉面", 0)
        if(data["tbk_item_get_response"] && data["tbk_item_get_response"]["total_results"] > 0)
          $c4 = data["tbk_item_get_response"]["results"]["n_tbk_item"]
        end
      end
      if $c5.size.zero?
        data  = get_tbk_search_json("酸辣粉", 0)
        if(data["tbk_item_get_response"] && data["tbk_item_get_response"]["total_results"] > 0)
          $c5 = data["tbk_item_get_response"]["results"]["n_tbk_item"]
        end
      end
      @c1 = $c1
      @c2 = $c2
      @c3 = $c3
      @c4 = $c4
      @c5 = $c5
      render 'lingshi', layout: 'lingshi'
      return
    end
    if request.host == "www.ichaopai.cc"
      @mobile_url = ''
      render "ichaopai"
      return
    end
    if request.host == "www.iquan.net" && is_device_mobile?
      redirect_to "http://ls.iquan.net", status: 302
      return
    end
    if request.host == "lanlan.iquan.net" || request.host == "m.iquan.net"
      redirect_to "http://ls.iquan.net", status: 302
      return
    end
    if !is_robot? && request.host.include?("pinpai.iquan.net")
      brand = ProductBrand.where(host: request.host, status: 1).select(:search_keyword).take
      not_found if brand.nil?
      redirect_to "https://www.iquan.net/zhekou/#{URI.encode(brand.search_keyword)}/", status: 302
      return
    end
    if @@compete_brands.nil? || Time.now.to_i % 600 == 0
      @@compete_brands = CompeteBrand.select(:title, :keywords, :description, :host).to_a
    end
    if !is_device_mobile? && request.host == "www.iquan.net"
      file = Rails.root.join("public/seo_articles").join("iquan_pc_home.html")
      if File.exists?(file) && !params[:is_refresh]
        render inline: File.read(file), layout: nil
        return
      end
      @compete_brands = @@compete_brands.sample(10)
      diyquan_home
      return
    else
      @compete_brands = @@compete_brands.sample(10)
    end
    if !is_robot? && is_device_mobile? && request.host == "m.iquan.net"
      redirect_to "http://ls.iquan.net"
      return
    end
    if !is_robot? 
      if is_device_mobile?
        redirect_to "http://ls.iquan.net"
      else
        diyquan_home
      end
      return
    end
    if @@product_brands.nil? || Time.now.to_i % 610 == 0
      @@product_brands = ProductBrand.where(status: 1).select(:title, :keywords, :host, :comments).to_a
    end
    @product_brands = @@product_brands
    @path = "/"
    if request.host == "www.zhequan.cc"
      render "zhequan"
      return
    end
    if request.host == "www.xiongmao123.com"
      @mobile_url = "http://m.xiongmao123.com"
      render "xiongmao"
      return
    end
    if request.host == "zhaoquan.iquan.net"
      @mobile_url = 'm.iquan.net'
      @title = "找券网 - 淘宝天猫优惠券大搜索 - 找券网"
      @description = "找券网 - 找券搜券淘券抢券拿券妈妈券宝宝券猪猪券内部券一网打尽，提供淘宝优惠券、天猫优惠券、内部优惠券、内部优惠卷、隐藏优惠券、隐藏券、隐藏优惠卷等实时查询服务，先搜索领券，再淘宝下单，专享爱券网折上折。每日更新大额优惠券、品牌优惠券、一折特价底价专场、9块9包邮白菜价好东西，加入搜藏，天天省钱 - 找券网。"
      @keywords = "找券,找券网,搜券,搜券网,zhaoquan,zhaoquanwang"
    end
    if request.host == "www.flowlover.com"
      @mobile_url = ''
      @title = "内部优惠券网站 - 天猫内部优惠券,天猫内部券,天猫隐藏券"
      @description = "内部优惠券网站,提供天猫内部优惠券搜索、查询、免费领取服务，天猫内部券、隐藏券一键搜索，免费领取后可直接下单抵扣,价格超实惠，千万淘宝天猫优惠券每天更新,上淘宝(天猫)购物先上内部优惠券网站，比双十一双十二更低！"
      @keywords = "内部优惠券,内部优惠券网站,天猫内部优惠券,天猫内部券,天猫隐藏券,天猫券"
    end
    if request.host == "www.youhui.vc"
      @mobile_url = ''
      @title = "优惠VC_淘宝内部优惠券,淘宝优惠券,淘宝隐藏券"
      @description = "优惠VC——淘宝内部优惠券网站,提供淘宝内部优惠券搜索、查询、免费领取服务，淘宝天猫内部券、隐藏券一键搜索，免费领取后可直接下单抵扣,价格超实惠，千万淘宝天猫优惠券每天更新,上淘宝(天猫)购物先上内部优惠券网站，比双十一双十二更低！"
      @keywords = "优惠vc,淘宝优惠券,淘宝内部券,淘宝隐藏券,淘宝内部优惠券,优惠券网站"
    end
    if request.host == "zhaoquan.shop"
      @mobile_url = 'http://zhaoquan.shop'
      @title = "找券网_淘宝优惠券,淘宝内部优惠券,天猫优惠券,淘宝内部券领取"
      @description = "找券网——淘宝内部优惠券网站,提供淘宝内部优惠券搜索、查询、免费领取服务，淘宝天猫内部券、隐藏券一键搜索，免费领取后可直接下单抵扣,价格超实惠，千万淘宝天猫优惠券每天更新,上淘宝(天猫)购物先上找券网，比双十一双十二更低！"
      @keywords = "找券网,淘宝优惠券,淘宝内部券,淘宝隐藏券,淘宝内部优惠券,天猫优惠券,天猫内部优惠券"
    end
    if request.host.include?(".youhui.iquan.net")
      brand = CompeteBrand.where(host: request.host).take
      not_found if brand.nil?
      @title = brand.title
      @keywords = brand.keywords
      @description = brand.description
    end
    if request.host.include?(".pinpai.iquan.net")
      brand = ProductBrand.where(host: request.host).take
      not_found if brand.nil?
      @title = brand.title
      @keywords = brand.keywords
      @description = brand.description
      @comments = brand.comments
    end
    @coupons = get_static_coupons('static_new_coupons')
  end

  def diyquan_home
    @coupons = []
    #@banners = Banner.where(status: 1).select(:link_url, :img_url).order("id desc").limit(5)
    @coupons_9kuai9 = get_coupon_9kuai9_data
    @links = Link.where(status: 1).to_a
    @shops = get_jd_shops
    render "diyquan/home", layout: "layouts/diyquan"
  end
  def m_diyquan_home
    @channel = 8
    @keyword = "生活"
    render "m_diyquan/home", layout: "layouts/m_diyquan"
  end
  def ddk_home
    @banners = [{"link_url" => "https://mobile.yangkeduo.com/duo_red_packet.html?pid=1781779_28462207&cpsSign=CR1781779_28462207_0efb46a4c7f487216f7b72b45348a04d&duoduo_type=2", "img_url" => "http://www.zhaoll.com/images/banner.png"}]
    @links = Link.where(status: 1).to_a
    @cates = get_cate_data
    @coupons_9kuai9 = get_coupon_9kuai9_data
    @coupons = []
    @top_keywords = get_hot_keywords_data.sample(8)
    @links = Link.where(status: 1).to_a
    render "ddk/home", layout: "layouts/ddk"
  end
  def frame_home
    @links = Link.where(status: 1).to_a
    render "home/frame_iquan", layout: "layouts/frame"
  end

end
