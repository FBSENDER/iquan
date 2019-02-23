module DiyquanHelper
  # tdk
  def fenlei_tdk
    cate_name = @category['name']
    @title = "#{cate_name},#{cate_name}优惠券_#{$website_name}"
    @description = "淘宝天猫隐藏#{cate_name}优惠券,#{cate_name}折扣，20元50元100元，先领券，再下单，专享淘宝折上折优惠。领取#{cate_name}优惠券，查看#{cate_name}打折特价信息 - #{$website_name}。"
    @page_keywords = "#{cate_name},#{cate_name}优惠,#{cate_name}优惠券,#{cate_name}淘宝优惠券,#{cate_name}折扣,特价#{cate_name}"
    @h1 = "#{cate_name}优惠券"
    @keyword = cate_name.split('/').first
    @seo_k = @keyword
    @path = request.path + "/"
    @links = Page.select(:anchor, :url)
  end

  def zhekou_rexiao_tdk
    @keyword = params[:keyword].force_encoding('utf-8')
    @title= "【热销#{@keyword}】_#{$website_name}"
    @description = "【热销#{@keyword}】淘宝天猫#{@keyword}优惠券，20元50元100元，先领券，再下单，专享淘宝折上折优惠。领取#{@keyword}优惠券，查看#{@keyword}打折特价信息——#{$website_name}"
    @page_keywords = "热销#{@keyword},#{@keyword},#{@keyword}优惠,#{@keyword}优惠券,#{@keyword}折扣,特价#{@keyword}"
    @big_keywords = $big_keywords
    @h1 = "热销#{@keyword}"
    @seo_k = @h1
    @path = request.path + "/"
    @links = []
  end

  def zhekou_tejia_tdk
    @keyword = params[:keyword].force_encoding('utf-8')
    @title= "【特价#{@keyword}】_#{$website_name}"
    @description = "【特价#{@keyword}】淘宝天猫#{@keyword}优惠券，20元50元100元，先领券，再下单，专享淘宝折上折优惠。领取#{@keyword}优惠券，查看#{@keyword}打折特价信息——#{$website_name}"
    @page_keywords = "#{@keyword},#{@keyword}优惠,#{@keyword}优惠券,#{@keyword}折扣,特价#{@keyword}"
    @big_keywords = $big_keywords
    @h1 = "特价#{@keyword}"
    @seo_k = @h1
    @path = request.path + "/"
    @links = []
  end

  def zhekou_dae_tdk
    @keyword = params[:keyword].force_encoding('utf-8')
    @title= "【#{@keyword}大额优惠券】_#{$website_name}"
    @description = "【#{@keyword}大额优惠券】淘宝天猫#{@keyword}优惠券，20元50元100元，先领券，再下单，专享淘宝折上折优惠。领取#{@keyword}优惠券，查看#{@keyword}打折特价信息——#{$website_name}"
    @page_keywords = "#{@keyword}大额优惠券,#{@keyword},#{@keyword}优惠,#{@keyword}优惠券,#{@keyword}折扣,特价#{@keyword}"
    @big_keywords = $big_keywords
    @h1 = "#{@keyword}大额优惠券"
    @seo_k = @keyword
    @path = request.path + "/"
    @links = []
  end

  def zhekou_yizhe_tdk
    @keyword = params[:keyword].force_encoding('utf-8')
    @title= "【一折#{@keyword}】_#{$website_name}"
    @description = "【一折#{@keyword}】淘宝天猫#{@keyword}优惠券，20元50元100元，先领券，再下单，专享淘宝折上折优惠。领取#{@keyword}优惠券，查看#{@keyword}打折特价信息——#{$website_name}"
    @page_keywords = "一折#{@keyword},#{@keyword},#{@keyword}优惠,#{@keyword}优惠券,#{@keyword}折扣,特价#{@keyword}"
    @big_keywords = $big_keywords
    @h1 = "一折#{@keyword}"
    @seo_k = @h1
    @path = request.path + "/"
    @links = []
  end

  def zhekou_tdk
    @keyword = params[:keyword].force_encoding('utf-8')
    @title= "【#{@keyword}】_#{@keyword}折扣_#{@keyword}优惠券_#{$website_name}"
    @description = "淘宝天猫隐藏#{@keyword}优惠券,#{@keyword}折扣,#{@keyowrd}包邮,20元50元100元优惠券,先领券,再下单,专享淘宝折上折优惠.领取#{@keyword}优惠券,查看#{@keyword}打折特价信息 - #{$website_name}"
    @page_keywords = "#{@keyword},#{@keyword}优惠,#{@keyword}优惠券,#{@keyword}折扣,特价#{@keyword}"
    @big_keywords = $big_keywords
    @h1 = @keyword
    @seo_k = @h1
    @path = request.path + "/"
    @links = []
  end

  def k_pinyin_tdk
    @keyword = @tag.keyword
    @title= "#{@keyword}_#{@keyword}价格_#{@keyword}品牌/报价/怎么样_#{$website_name}"
    @description = "找#{@keyword}，就上爱券网iquan.net，数以万计的#{@keyword}优质商品供您挑选，包括品牌，价格，图片，厂家，产地，材料等，爱券网让网购更加方便又省钱！"
    @page_keywords = "#{@keyword},#{@keyword}价格,#{@keyword}报价,#{@keyword}品牌,#{@keyword}怎么样,#{@keyword}厂家,#{@keyword}店铺,#{@keyword}图片"
    @big_keywords = $big_keywords
    @h1 = @keyword
    @seo_k = @h1
    @path = request.path + "/"
    @links = []
  end

  def baokuan_tdk
    @title = "淘宝爆款_#{$website_name}"
    @description = "#{$website_name} - 淘宝爆款热销产品,爆款热卖进行中,网站内最热门的优惠券免费领！"
    @page_keywords = "爆款,爆款网,热销,热销产品,热门优惠券"
    @h1 = "淘宝爆款"
    @path = request.path + "/"
    @links = []
  end

  def k9_tdk
    @title = "9块9,9.9包邮,9块邮_九块九全场包邮官网"
    @description = "#{$website_name} - 全场九块九包邮，九块九包邮专场，本频道所有商品券后价九块九免费包邮到家，想要买到九块九包邮的精品商品请上省钱快报。9.9全场包邮到家-9.9包邮专场，买到就是赚！"
    @page_keywords = "9块9包邮,九块九包邮网,9.9包邮,巨划算九块九包邮,每天9.9包邮,九块九,9.9元全场包邮,全场9.9包邮,9.9元全国包邮"
    @h1 = "9块9包邮网"
    @path = request.path + "/"
    @links = []
  end

  def k20_tdk
    @title = "十块购官网,20元封顶,ShiKuaiGou,10KuaiGou"
    @description = "#{$website_name} - 十块购官网（ShiKuaiGou.Com）消费导购平台，汇聚淘宝 京东等平台9.9包邮及19.9包邮特价好货。十块购为您提供精明的购物决策，我们致力于以客观中立的态度，为您推荐最具品质和性价比的消费信息。"
    @page_keywords = "十块购,十元包邮,10块购,十块邮,十块购官网,shikuaigou,10kuaigou"
    @h1 = "十块购"
    @path = request.path + "/"
    @links = []
  end

  def zhuanchang_tdk
    @title = "优惠专场#{@zhuanchang_id}_#{$website_name}"
    @description = "专场特卖- #{@title} - #{$website_name}。"
    @page_keywords = @title
    @h1 = @title
    @path = request.path + "/"
    @links = []
  end
  
  def quan_detail_tdk
    @title = "#{@coupon['title']}优惠券_#{$website_name}"
    @description = "#{@coupon['title']},原价#{@coupon['raw_price']}元,领券立减#{@coupon['gap_price']}元,月销#{@coupon['month_sales']}件,淘宝/天猫热销中,优惠券马上领。#{@coupon['title']}优惠券如何领取？首先点击页面上的立即领券按钮，来到淘宝天猫的优惠券领取页，在点击立即领券，这时系统会提示您登陆淘宝账户，登录成功后，就可以领取优惠券，下单享受立减优惠了 - #{$website_name}"
    @page_keywords = "#{@coupon['title']},#{@coupon['title']}优惠券"
    @big_keywords = $big_keywords
    @h1 = "#{@coupon['title']}优惠券"
    @path = request.path + "/"
    @links = []
  end

  def map_k_tdk
    @title = "淘宝天猫店铺优惠券_旗舰店优惠券_通用优惠券"
    if @page > 0
      @title = @title + "_第#{@page + 1}页"
    end
    @description = "#{$website_name} - 提供淘宝店铺优惠券、天猫店铺优惠券、天猫旗舰店优惠券、通用优惠卷、淘宝通用优惠券、天猫通用券、隐藏优惠卷等实时查询服务找券网服务，先搜索领券，再淘宝下单，专享#{$website_name}折上折。每日更新大额优惠券、品牌优惠券、一折特价底价专场、9块9包邮白菜价好东西，加入搜藏，天天省钱，找券就来 - #{$website_name}。"
    @page_keywords = "淘宝店铺优惠券,天猫店铺优惠券,天猫旗舰店优惠券,天猫通用优惠券,淘宝通用优惠券,通用优惠券" 
    @path = "/map_k/"
    @h1 = "淘宝天猫旗舰店铺通用优惠券"
    @links = []
  end
end
