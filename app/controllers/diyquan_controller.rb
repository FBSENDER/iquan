class DiyquanController < ApplicationController
  include DiyquanHelper
  skip_before_action :verify_authenticity_token

  $tbkus = KeywordTbku.all
  def refresh_tbkus 
    $tbkus = KeywordTbku.all
    render plain: "OK"
  end

  def apply_high_commission(product_id, pid)
    url = "https://www.heimataoke.com/api-zhuanlian?appkey=#{$heima_appkey}&appsecret=#{$heima_appsecret}&sid=28&pid=#{pid}&num_iid=#{product_id}"
    JSON.parse(Net::HTTP.get(URI(url)))
  end

  def buy
    pid = is_device_mobile?? $pid_new : $pid
    pid = params[:pid] if params[:pid]
    url = "https://uland.taobao.com/coupon/edetail?tj1=1&tj2=1&activityId=#{params[:activity_id]}&itemId=#{params[:id]}&pid=#{pid}"
    if !is_robot?
      begin
        result = apply_high_commission(params[:id], pid)
        url = "#{result["coupon_click_url"]}&activityId=#{params[:activity_id]}" unless result["coupon_click_url"].nil?
        redirect_to url, status: 302
        click = ProductClick.new
        click.product_id = params[:id].to_i
        click.activity_id = params[:activity_id]
        click.commission_rate = result["max_commission_rate"].nil? ? 0 : result["max_commission_rate"].to_f
        click.status =  click.commission_rate == 0 ? 0 : 1
        click.save
        return
      rescue 
      end
    end
    redirect_to url, status: 302
  end

  def fenlei
    return if redirect_pc_to_mobile
    page = params[:page].nil? ? 0 : params[:page].to_i
    page_size = 40
    @pinyin = params[:pinyin]
    @category = get_cate_collection(@pinyin)
    fenlei_tdk
    if is_robot?
      @coupons = get_static_coupons(@keyword)
    else
      #result = JSON.parse(fenlei_coupon_list(params[:pinyin], params[:sort_type], params[:price], page, page_size))
      #@coupons = result["data"]["coupon_list"]
      @coupons = []
    end
    if is_device_mobile?
      if is_robot?
        render "m_diyquan/fenlei", layout: "layouts/m_diyquan"
      else
        redirect_to URI.encode("http://#{$mobile_host}/saber/search?pid=#{$pid_new}&search=#{@keyword}"), status: 302
      end
    else
      if is_robot?
        render "diyquan/fenlei", layout: "layouts/diyquan"
      else
        render "diyquan/lanlan_fenlei", layout: "layouts/diyquan"
      end
    end
  end

  def lanlan_fenlei
    return if redirect_pc_to_mobile
    @cid = params[:cid]
    @cid_1 = params[:cid_1]
    @lanlan_cates = $lanlan_cates.sort{|a, b| a["cid"].to_i <=> b["cid"].to_i}
    @lanlan_category = $lanlan_cates.select{|c| c["cid"] == @cid || c["cid"] == params[:cid_1]}.first
    if @lanlan_category.nil?
      not_found
      return
    end
    @category_name = params[:category_name] || @lanlan_category["name"]
    @coupons = []
    render "diyquan/lanlan_fenlei_new", layout: "layouts/diyquan"
  end

  def zhekou_rexiao
    zhekou_rexiao_tdk
    zhekou_render(1)
  end
  def zhekou_tejia
    zhekou_tejia_tdk
    zhekou_render(2)
  end
  def zhekou_dae
    zhekou_dae_tdk
    zhekou_render(4)
  end
  def zhekou_yizhe
    zhekou_yizhe_tdk
    zhekou_render(3)
  end

  def zhekou
    zhekou_tdk
    zhekou_render(0)
  end

  def zhekou_render(sort_type)
    return if redirect_pc_to_mobile
    @taodianjin_pid = is_device_mobile? ? $taodianjin_mobile_pid : $taodianjin_pc_pid
    if is_keyword_url?(@keyword)
      id = get_tb_id(@keyword)
      if id
        redirect_to "http://#{$pc_host}/buy/#{id}/?activity_id=", status: 302
        log = SearchUrlLog.new
        log.item_id = id.to_i
        log.save
      else
        redirect_to "/query/noresult/?keyword=#{URI.encode(@keyword)}", status: 302
      end
      return
    end
    if $tbkus.any?{|tbku| tbku.keyword == @keyword}
      @shops = Shop.where(id: (1..1000).to_a.sample(20)).select(:title, :nick)
      tbku = $tbkus.select{|tbku| tbku.keyword == @keyword}.first
      data = get_tbk_uatm_json(tbku.tbku_id)
      if data && data["tbk_uatm_favorites_item_get_response"]["total_results"] > 0
        @keywords = get_suggest_keywords_new(@keyword)
        @path = request.path + "/"
        @coupons = data["tbk_uatm_favorites_item_get_response"]["results"]["uatm_tbk_item"]
        if is_device_mobile?
          render "m_diyquan/uatm_zhekou", layout: "layouts/m_diyquan"
        else
          render "uatm_zhekou"
        end
        save_zhekou_keyword(@keyword)
        return
      end
    end
    
    unless is_robot?
      #result = JSON.parse(search_coupon_list(params[:keyword], params[:sort_type], params[:price], 0, 40))
      #@coupons = result["data"]["coupon_list"]
      @shops = []
      if is_taobao_title?(@keyword)
        @coupons = []
      else
        @coupons = JSON.parse(lanlan_search_coupon_list(@keyword, params[:sort_type], params[:price], 1, 20))["result"]
      end
      @sort_type = sort_type
      if(@coupons.nil? || @coupons.size <= 0)
        tb_coupon_result = get_tbk_coupon_search_json(@keyword, 218532065, 0)
        if tb_coupon_result && tb_coupon_result["tbk_dg_item_coupon_get_response"]["results"]  && tb_coupon_result["tbk_dg_item_coupon_get_response"]["results"]["tbk_coupon"] && tb_coupon_result["tbk_dg_item_coupon_get_response"]["results"]["tbk_coupon"].size > 0
          @keywords = get_suggest_keywords_new(@keyword)
          @coupons = tb_coupon_result["tbk_dg_item_coupon_get_response"]["results"]["tbk_coupon"]
          if is_device_mobile?
            render "m_diyquan/tb_zhekou", layout: "layouts/m_diyquan"
          else
            render "tb_zhekou"
          end
          save_zhekou_keyword(@keyword)
          return
        end
        tb_result = get_tbk_search_json(@keyword, 0)
        if tb_result && tb_result["tbk_item_get_response"]["total_results"] > 0
          @keywords = get_suggest_keywords_new(@keyword)
          @zhekous = tb_result["tbk_item_get_response"]["results"]["n_tbk_item"]
          if is_device_mobile?
            render "m_diyquan/tb_zhekou", layout: "layouts/m_diyquan"
          else
            render "tb_zhekou"
          end
          save_zhekou_keyword(@keyword)
          return
        end
        redirect_to "/query/noresult/?keyword=#{URI.encode(@keyword)}", status: 302
        save_zhekou_keyword(@keyword)
        return
      end
    else
      @coupons = get_static_coupons(@keyword)
      @shops = Shop.where(source_id: @coupons.map{|c| c["seller_id"]}.uniq).select(:title, :nick)
      @sort_type = sort_type
      save_zhekou_keyword(@keyword)
    end
    @keywords = get_suggest_keywords_new(@keyword)
    @path = request.path + "/"
    if is_device_mobile?
      if is_robot?
        render "m_diyquan/zhekou", layout: "layouts/m_diyquan"
      else
        redirect_to URI.encode("http://#{$mobile_host}/saber/search?pid=#{$pid_new}&search=#{@keyword}"), status: 302
      end
    else
      if is_robot?
        render "zhekou", layout: "layouts/diyquan"
      else
        render "lanlan_zhekou", layout: "layouts/diyquan"
      end
    end
    save_zhekou_keyword(@keyword)
  end

  def save_zhekou_keyword(keyword)
    begin
      return if SuggestKeyword.exists?(keyword: keyword)
      sk = SuggestKeyword.new
      sk.keyword = keyword
      sk.sks = ''
      sk.save
    rescue
    end
  end

  def baokuan
    return if redirect_pc_to_mobile
    baokuan_tdk
    if is_robot?
      @coupons = get_static_coupons('static_hot_coupons')
    else
      @coupons = []
    end
    if is_device_mobile?
      render "m_diyquan/baokuan", layout: "layouts/m_diyquan"
    else
      if is_robot?
        render "diyquan/baokuan", layout: "layouts/diyquan"
      else
        render "diyquan/lanlan_baokuan", layout: "layouts/diyquan"
      end
    end
  end

  def k9
    return if redirect_pc_to_mobile
    k9_tdk
    if is_robot?
      @coupons = get_static_coupons('static_k9_coupons')
    else
      @coupons = []
    end
    if is_device_mobile?
      render "m_diyquan/k9", layout: "layouts/m_diyquan"
    else
      if is_robot?
        render "diyquan/k9", layout: "layouts/diyquan"
      else
        render "diyquan/lanlan_k9", layout: "layouts/diyquan"
      end
    end
  end

  def k20
    return if redirect_pc_to_mobile
    k20_tdk
    if is_robot?
      @coupons = get_static_coupons('static_k20_coupons')
    else
      @coupons = []
    end
    if is_device_mobile?
      render "m_diyquan/k20", layout: "layouts/m_diyquan"
    else
      if is_robot?
        render "diyquan/k20", layout: "layouts/diyquan"
      else
        render "diyquan/lanlan_k20", layout: "layouts/diyquan"
      end
    end
  end

  def zhuanchang
    return if redirect_pc_to_mobile
    @zhuanchang_id = params[:id]
    zhuanchang_tdk
    #result = JSON.parse(zhuanchang_coupon_list(params[:id]))
    @coupons = get_static_coupons('static_new_coupons')
    #@coupons = result["data"]["coupon_list"]
    if is_device_mobile?
      render "m_diyquan/zhuanchang", layout: "layouts/m_diyquan"
    end
  end

  def search
    @hot_keywords = get_hot_keywords
    render "m_diyquan/search", layout: "layouts/m_diyquan"
  end

  def quick_search
    @hot_keywords = get_hot_keywords
    render "m_diyquan/quick_search", layout: "layouts/m_diyquan"
  end

  def quick_search_title
    @keyword = params[:keyword].strip
    @is_taokouling = params[:kouling].nil? ? 0 : params[:kouling].to_i
    unless is_taobao_title?(@keyword)
      render json: {status: 5, url: "/zhekou/#{URI.encode(@keyword)}/"}
      quick_search_log(5, @is_taokouling, 0)
      return
    end
    tb_coupon_result = get_tbk_coupon_search_json(@keyword, 218532065, 0)
    if tb_coupon_result && tb_coupon_result["tbk_dg_item_coupon_get_response"]["results"]  && tb_coupon_result["tbk_dg_item_coupon_get_response"]["results"]["tbk_coupon"] && tb_coupon_result["tbk_dg_item_coupon_get_response"]["results"]["tbk_coupon"].size == 1
      cp = tb_coupon_result["tbk_dg_item_coupon_get_response"]["results"]["tbk_coupon"].first
      coupon_price = cp["coupon_info"].match(/减(\d+)元/)[1]
      render json: {status: 1, url: "/buy/#{cp["num_iid"]}/", price: coupon_price, end_time: cp["coupon_end_time"]}
      quick_search_log(1, @is_taokouling, 1)
      return
    elsif tb_coupon_result && tb_coupon_result["tbk_dg_item_coupon_get_response"]["results"]  && tb_coupon_result["tbk_dg_item_coupon_get_response"]["results"]["tbk_coupon"] && tb_coupon_result["tbk_dg_item_coupon_get_response"]["results"]["tbk_coupon"].size > 1
      render json: {status: 2, url: "/zhekou/#{URI.encode(@keyword)}/", price: 5}
      quick_search_log(2, @is_taokouling, 1)
      return
    end
    tb_result = get_tbk_search_json(@keyword, 0)
    if tb_result && tb_result["tbk_item_get_response"]["total_results"] == 1
      pd = tb_result["tbk_item_get_response"]["results"]["n_tbk_item"].first
      render json: {status: 3, url: "http://item.taobao.com/item.htm?id=#{pd["num_iid"]}", price: pd["zk_final_price"]}
      quick_search_log(3, @is_taokouling, 1)
      return 
    elsif tb_result && tb_result["tbk_item_get_response"]["total_results"] > 1
      render json: {status: 4, url: "/zhekou/#{URI.encode(@keyword)}/"}
      quick_search_log(4, @is_taokouling, 1)
      return
    end
    render json: {status: -1}
    quick_search_log(-1, @is_taokouling, 1)
  end

  def quick_search_log(status, is_taokouling, is_title)
    log = QuickSearchLog.new
    log.host = request.host
    log.ip = request.ip
    log.keyword = @keyword
    log.status = status
    log.is_taokouling = is_taokouling
    log.is_title = is_title
    log.save
  end

  def noresult
    @keyword = params[:keyword]
    @coupons = JSON.parse(baokuan_coupon_list(0, 40))["data"]["coupon_list"]
    @hot_keywords = get_hot_keywords
  end

  def get_categories
    render json: get_categories_json
  end

  def get_coupons_index
    render json: index_coupon_list(params[:page], params[:pagesize])
  end

  def get_lanlan_coupons_index
    render json: lanlan_coupon_list(0, 7, params[:page], params[:pagesize])
  end

  def get_coupons_fenlei
    render json: fenlei_coupon_list(params[:pinyin], params[:sort_type], params[:price], params[:page], params[:pagesize])
  end

  def get_coupons_search
    render json: search_coupon_list(params[:keyword], params[:sort_type], params[:price], params[:page], params[:pagesize])
  end

  def get_lanlan_coupons_fenlei
    render json: lanlan_coupon_list(params[:cid], params[:sort_type], params[:page], params[:pagesize])
  end

  def get_lanlan_coupons_search
    render json: lanlan_search_coupon_list(params[:keyword], params[:sort_type], params[:price], params[:page], params[:pagesize])
  end

  def get_lanlan_coupons_type
    render json: lanlan_type_coupon_list(params[:type], params[:sort_type], params[:page], params[:pagesize])
  end

  def get_coupons_hot
    render json: baokuan_coupon_list(params[:page], params[:pagesize]) 
  end

  def get_coupons_k9
    render json: k9_coupon_list(params[:page], params[:pagesize])
  end

  def get_coupons_k20
    render json: k20_coupon_list(params[:page], params[:pagesize])
  end

  def get_cate_collection(pinyin)
    #begin
    #  return JSON.parse(get_cate_collection_json(pinyin))["data"]
    #rescue
    #  return nil
    #end
    cc = CateCollection.where(pinyin: pinyin, status: 1,collection_type: 2).select(:name, :collection_id, :pid, :pinyin).take
    return nil if cc.nil?
    c1 = CateCollection.where(collection_type: 2, status: 1, pid: 0).select(:name, :collection_id, :pinyin).to_a
    if cc.pid == 0
      c2 = CateCollection.where(pid: cc.collection_id,status: 1, collection_type: 2).select(:name, :collection_id, :pinyin, :pid).to_a
    else
      c2 = CateCollection.where(pid: cc.pid,status: 1, collection_type: 2).select(:name, :collection_id, :pinyin, :pid).to_a
    end
    data = {}
    data["cate_collection_id"] = cc.collection_id
    data["pinyin"] = cc.pinyin
    data["pid"] = cc.pid
    data["name"] = cc.name
    data["cate"] = []
    c1.each do |c|
      h = {}
      h["cate_collection_id"] = c.collection_id
      h["pinyin"] = c.pinyin
      h["name"] = c.name
      h["pid"] = 0
      data["cate"] << h
    end
    data["subclass"] = []
    c2.each do |c|
      h = {}
      h["cate_collection_id"] = c.collection_id
      h["pinyin"] = c.pinyin
      h["name"] = c.name
      h["pid"] = c.pid
      data["subclass"] << h
    end
    data
  end

  def get_coupon_by_id
    return if redirect_pc_to_mobile
    if is_robot?
      cp = CouponSuggestion.where(coupon_id: params[:id].to_i).take
      product = Product.where(item_id: cp.item_id).take unless cp.nil?
      if product.nil?
        result = JSON.parse(get_coupon_json(params[:id]))
        @coupon = result["data"]["coupon_info"]
        @category = result["data"]["cate_collection_list"]
      else
        @shops = Shop.where(source_id: product.seller_id).select(:nick, :title).to_a
        @related_coupons = get_static_coupons(product.cate_leaf_name.split('/').first, 20)
        @same_seller_coupons = get_static_coupons_by_seller_id(product.seller_id, 20)
        @coupon = {}
        @coupon["title"] = cp.title
        @coupon["raw_price"] = product.price
        @coupon["gap_price"] = 0
        @coupon["coupon_price"] = 0
        @coupon["month_sales"] = product.volume
        @coupon["cate_info"] = {}
        @coupon["cate_info"]["name"] = product.cate_name.split('/').first
        @coupon["subcate_info"] = {}
        @coupon["subcate_info"]["name"] = product.cate_leaf_name.split('/').first
        @coupon["dateline"] = Time.now.to_i + 24*60*60
        @coupon["url"] = ''
        @coupon["item_id"] = product.item_id
        @coupon["post_free"] = 1
        @coupon["platform_id"] = product.is_tmall + 1
        @coupon["pic"] = product.pic_url
        @category = nil
      end
    else
      if is_device_mobile?
        rk = get_referer_search_keyword
        rt = get_title_from_search_keyword(rk)
        if rt
          redirect_to "/zhekou/#{URI.encode(rt)}/", status: 302
          @keyword = rt
          quick_search_log(6, 1, 1)
          return
        end
      end
      result = JSON.parse(get_coupon_json(params[:id]))
      @coupon = result["data"]["coupon_info"]
      to_lanlan = 0
      if !is_robot? && is_device_mobile?
        lanlan_coupon = JSON.parse(lanlan_coupon_detail(@coupon['item_id']))
        if llc = lanlan_coupon["result"]
          to_lanlan = 1
          aid = llc['couponUrl'].match(/activityId=(\w*)/)[1]
          redirect_url = "http://#{$mobile_host}/saber/detail?activityId=#{aid}&itemId=#{llc["itemId"]}&pid=#{$pid_new}&forCms=1"
          redirect_to redirect_url, status: 302
        else
          aid = @coupon['url'].match(/activityId=(\w*)/)
          aid = aid.nil? ? '' : aid[1]
          redirect_url = "http://#{$mobile_host}/buy/#{@coupon['item_id']}/?activity_id=#{aid}"
          taobao_product = Product.where(item_id: @coupon['item_id'].to_i).take
          if taobao_product
            redirect_url = URI.encode("http://#{$mobile_host}/saber/search?pid=#{$pid_new}&search=#{taobao_product.title.gsub('/','')}&super=1")
          end
          redirect_to redirect_url, status: 302
        end
        referer = '-'
        if ref = request.referer
          referer = URI(ref).host
        end
        click = ProductClick.new
        click.product_id = @coupon['item_id']
        click.activity_id = aid
        click.referer = referer
        click.to_lanlan = to_lanlan
        click.save
        return 
      end
      @category = result["data"]["cate_collection_list"]
    end
    if @coupon.nil?
      not_found
      return
    end
    #可能没有推荐 要兜底
    @coupons = get_static_coupons('static_new_coupons', 20)
    @hot_coupons = get_static_coupons('static_hot_coupons', 20)
    cate_collection_id = 0
    if(@category && @category.size > 0)
      cate_collection_id = @category[0]["cate_collection_id"]
    end
    @suggest_keywords = get_sk_by_coupon_id(params[:id].to_i)
    if @suggest_keywords.size.zero? && @category && @category.size > 0
      @suggest_keywords = get_suggest_keywords_new(@category[-1]["name"])
    end
    @shops ||= Shop.where(id: (1..1000).to_a.sample(20)).select(:title, :nick)
    quan_detail_tdk
    unless is_robot? && @coupon["coupon_price"].to_i == 0
      mmcoupon = apply_high_commission(@coupon["item_id"], $pid)
      if mmcoupon["coupon_start_time"]
        @coupon["gap_price"] = mmcoupon["coupon_info"].match(/减(\d+)元/)[1].to_i
        @coupon["coupon_price"] = (@coupon["raw_price"].to_f - @coupon["gap_price"]).round(2)
        tt = mmcoupon["coupon_end_time"].match(/(\d+)-(\d+)-(\d+)/)
        @coupon["dateline"] = Time.new(tt[1].to_i, tt[2].to_i, tt[3].to_i).to_i
      end
    end
    render :quan_detail
    save_coupon_suggestion(@coupon)
  end

  def save_coupon_suggestion(coupon)
    return if CouponSuggestion.exists?(coupon_id: @coupon['coupon_id'].to_i)
    cs = CouponSuggestion.new
    cs.coupon_id = coupon['coupon_id'].to_i
    cs.title = coupon['title']
    cs.item_id = coupon['item_id'].to_i
    cs.save
  end

  def get_sk_by_coupon_id(coupon_id)
    begin
      ckr = CidKeywordRelation.where(coupon_id: coupon_id).take
      return [] if ckr.nil?
      get_suggest_keywords_new(ckr.keyword)
    rescue
      return []
    end
  end



  def lanlan_download
    #user_agent = request.headers["HTTP_USER_AGENT"]
    #if user_agent.present? && user_agent =~ /\b(iPhone)\b/i
    #  redirect_to "http://u.51huiyou.cn/x/5539e674", status: 302
    #else
    #  redirect_to "http://apphtml.ffquan.com/index.php?r=index/down&app_id=550416?t=1512729543", status: 302
    #end
    redirect_to "http://u.pingouwu.cn/x/839a0ca8", status: 302
    if !is_robot?
      one_click = AppDownload.new
      one_click.ip = request.remote_ip
      one_click.save
    end
  end

  def page
    return if redirect_pc_to_mobile
    @page_info = Page.where(pinyin: params[:pinyin]).take
    not_found if @page_info.nil?
    @sort_type = 0
    if is_robot?
      @coupons = get_static_coupons(@page_info.search_keyword)
    else
      result = JSON.parse(search_coupon_list(@page_info.search_keyword, nil, nil, 0, 40))
      @coupons = result["data"]["coupon_list"] || []
    end
    #if(@coupons.nil? || @coupons.size <= 0)
    #  redirect_to "/query/noresult/?keyword=#{URI.encode(@keyword)}", status: 302
    #  return
    #end
    @title = @page_info.title
    @description = @page_info.description
    @desc_ext = @page_info.desc_ext
    @page_info.core_keywords.split(',').each do |k|
      @desc_ext = @desc_ext.gsub(k, "<strong>#{k}</strong>")
    end
    @keywords = @page_info.keywords
    @search_keyword = @page_info.search_keyword
    @suggest_keywords = get_suggest_keywords_new(@page_info.search_keyword)
    @path = request.path + "/"
    @seo_k = @page_info.search_keyword 
    @keyword = @page_info.search_keyword 
    @links = Page.select(:anchor, :url)
    @h1 = @page_info.anchor
    if !is_robot? && is_device_mobile?
      render "m_diyquan/page", layout: "layouts/m_diyquan"
    else
      render "page"
    end
  end

  def k_pinyin
    return if redirect_pc_to_mobile
    @tag = Tag.where(pinyin: params[:pinyin]).take
    not_found if @tag.nil?
    @coupons = get_static_coupons(@tag.keyword)
    not_found if(@coupons.nil? || @coupons.size <= 0)
    @keywords = get_suggest_keywords_new_new(@tag.keyword)
    @shops = Shop.where(source_id: @coupons.map{|c| c["seller_id"]}.uniq).select(:title, :nick)
    k_pinyin_tdk
    if is_device_mobile?
      render "m_diyquan/zhekou", layout: "layouts/m_diyquan"
    else
      render "zhekou", layout: "layouts/diyquan"
    end
  end

  def get_tbk_search_json(keyword, page_no)
    tbk = Tbkapi::Taobaoke.new
    JSON.parse(tbk.taobao_tbk_item_get(keyword, $taobao_app_id, $taobao_app_secret, page_no + 1,50))
  end

  def get_tbk_coupon_search_json(keyword, adzone, page_no)
    tbk = Tbkapi::Taobaoke.new
    JSON.parse(tbk.taobao_tbk_dg_item_coupon_get(keyword, adzone, $taobao_app_id, $taobao_app_secret, page_no + 1,50))
  end

  def get_tbk_uatm_json(tbku_id)
    tbk = Tbkapi::Taobaoke.new
    JSON.parse(tbk.taobao_tbk_uatm_favorites_item_get(tbku_id, $taobao_adzone_id, $taobao_unid, $taobao_app_id, $taobao_app_secret, 2, 1, 100))
  end

  def map_k
    @page = params[:page].to_i
    @page = @page == 0 ? 0 : @page - 1
    @ks = SearchResult.where("coupon_count >= 100").select(:id, :keyword).order(:id).limit(500).offset(500 * @page)
    @kss = Tag.where("coupon_count >= 100").select(:id, :keyword, :pinyin).order(:id).limit(500).offset(500 * @page)
    @total_page = 20
    not_found if @ks.size.zero?
    map_k_tdk
  end

  def duoshou
    rk = get_referer_search_keyword
    rt = get_title_from_search_keyword(rk)
    if rt
      redirect_to "http://m.iquan.net/zhekou/#{URI.encode(rt)}/?source=baidusem_d", status: 302
      @keyword = rt
      quick_search_log(7, 1, 1)
      return
    else
      redirect_to "http://m.uuhaodian.com/index.php?r=index/wap&source=baidusem_d", status: 302
    end
  end

end
