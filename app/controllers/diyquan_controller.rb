class DiyquanController < ApplicationController
  include DiyquanHelper
  skip_before_action :verify_authenticity_token

  def fenlei
    return if redirect_pc_to_mobile
    page = params[:page].nil? ? 0 : params[:page].to_i
    page_size = 40
    @pinyin = params[:pinyin]
    @category = get_cate_collection(@pinyin)
    fenlei_tdk
    @coupons = []
    unless is_robot?
      if is_device_mobile?
        redirect_to "http://m.uuhaodian.com/index.php?r=/search/tblist&keyWords=#{URI.encode_www_form_component(@keyword)}", status: 302
      else
        redirect_to "/zhekou/#{URI.encode_www_form_component(@keyword)}/", status: 302
      end
      return
    end
    @zhekous = []
    data  = get_tbk_search_json(@keyword, 1)
    if data["tbk_dg_material_optional_response"] && data["tbk_dg_material_optional_response"]["result_list"] && data["tbk_dg_material_optional_response"]["result_list"]["map_data"].size > 0
      @zhekous = data["tbk_dg_material_optional_response"]["result_list"]["map_data"]
    end
    @keywords = ZhekouKeyword.where(keyword: params[:pinyin]).pluck(:word)
    if is_device_mobile?
      render "m_diyquan/fenlei", layout: "layouts/m_diyquan"
    else
      render "diyquan/fenlei", layout: "layouts/diyquan"
    end
  end

  def zhekou_rexiao
    zhekou_rexiao_tdk
    @ss_id = 2
    zhekou_render(1)
  end
  def zhekou_tejia
    zhekou_tejia_tdk
    @ss_id = 3
    zhekou_render(2)
  end
  def zhekou_dae
    zhekou_dae_tdk
    @ss_id = 4
    zhekou_render(4)
  end
  def zhekou_yizhe
    zhekou_yizhe_tdk
    @ss_id = 5
    zhekou_render(3)
  end

  def zhekou_jd
    zhekou_jd_tdk
    @ss_id = 1
    cookies[:ff_platform] = 2
    zhekou_render(0)
  end

  def zhekou_pdd
    zhekou_pdd_tdk
    @ss_id = 1
    cookies[:ff_platform] = 3
    zhekou_render(0)
  end

  def zhekou
    zhekou_tdk
    @ss_id = 1
    zhekou_render(0)
  end

  def zhekou_render(sort_type)
    return if redirect_pc_to_mobile
    @coupons = []
    @zhekous = []
    @shops = []
    @sort_type = sort_type
    @keywords = ZhekouKeyword.where(keyword: @keyword).pluck(:word)
    @sks = [] 
    @related_k = []
    @nicks = []
    @path = request.path + "/"
    sk = SuggestKeyword.where(keyword: @keyword).select(:sks).take
    ss = SuggestShop.where(keyword: @keyword).select(:nicks).take
    unless sk.nil?
      @sks = sk.sks.split(',')
      @related_k = @sks.sample(10)
      @sks -= @related_k
    end
    unless ss.nil?
      @nicks = ss.nicks.split(',')
    end
    get_top_query
    if is_device_mobile?
      render "dazhe/zhekou", layout: "layouts/dazhe"
    else
      render "zhekou", layout: "layouts/diyquan"
    end
  end

  def baokuan
    return if redirect_pc_to_mobile
    baokuan_tdk
    @coupons = []
    unless is_robot?
      redirect_to "http://www.uuhaodian.com?from=shikuai", status: 302
      return
    end
    if is_device_mobile?
      render "m_diyquan/baokuan", layout: "layouts/m_diyquan"
    end
  end

  def k9
    return if redirect_pc_to_mobile
    k9_tdk
    @coupons = []
    unless is_robot?
      redirect_to "http://www.uuhaodian.com?from=shikuai", status: 302
      return
    end
    if is_device_mobile?
      render "m_diyquan/k9", layout: "layouts/m_diyquan"
    end
  end

  def k20
    return if redirect_pc_to_mobile
    k20_tdk
    @coupons = []
    unless is_robot?
      redirect_to "http://www.uuhaodian.com?from=shikuai", status: 302
      return
    end
    if is_device_mobile?
      render "m_diyquan/k20", layout: "layouts/m_diyquan"
    end
  end

  def zhuanchang
    return if redirect_pc_to_mobile
    @zhuanchang_id = params[:id]
    zhuanchang_tdk
    @coupons = []
    unless is_robot?
      redirect_to "http://www.uuhaodian.com?from=shikuai", status: 302
      return
    end
    if is_device_mobile?
      render "m_diyquan/zhuanchang", layout: "layouts/m_diyquan"
    end
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
    render json: lanlan_index_coupon_list(params[:page], params[:pagesize])
  end

  def get_coupons_fenlei
    render json: fenlei_coupon_list(params[:pinyin], params[:sort_type], params[:price], params[:page], params[:pagesize])
  end

  def get_coupons_search
    render json: search_coupon_list(params[:keyword], params[:sort_type], params[:price], params[:page], params[:pagesize])
  end

  def get_lanlan_coupons_search
    render json: lanlan_search_coupon_list(params[:keyword], params[:sort_type], params[:price], params[:page], params[:pagesize])
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
    cp = CouponSuggestion.where(coupon_id: params[:id].to_i).take
    product = Product.where(item_id: cp.item_id).take unless cp.nil?
    if product.nil?
      redirect_to "http://www.shikuaigou.com", status: 301
      return
    else
      unless is_robot?
        if is_device_mobile?
          redirect_to "http://m.uuhaodian.com/index.php?r=index%2Fsearch&s_type=1&kw=#{URI.encode_www_form_component(product.title)}&from=m_iquan", status: 302
        else
          redirect_to "http://www.uuhaodian.com/query/#{URI.encode_www_form_component(product.title)}/?from=iquan", status: 302
        end
        return
      end

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
    if @coupon.nil?
      not_found
      return
    end
    #可能没有推荐 要兜底
    @coupons = []
    @hot_coupons = []
    cate_collection_id = 0
    if(@category && @category.size > 0)
      cate_collection_id = @category[0]["cate_collection_id"]
    end
    @suggest_keywords = []
    @shops ||= Shop.where(id: (1..1000).to_a.sample(20)).select(:title, :nick)
    quan_detail_tdk
    render :quan_detail
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
    redirect_to "https://api.uuhaodian.com/uu/xiaohui_app", status: 302
    if !is_robot?
      one_click = AppDownload.new
      one_click.ip = request.remote_ip
      one_click.save
    end
  end

  def map_k
    @page = params[:page].to_i
    @page = @page == 0 ? 0 : @page - 1
    @sks = SuggestKeyword.select(:id, :keyword, :sks).limit(100).offset(100 * @page)
    @total_page = @page + 100
    not_found if @sks.size.zero?
    map_k_tdk
  end

  def get_tbk_search_json(keyword, page_no)
    tbk = Tbkapi::Taobaoke.new
    JSON.parse(tbk.taobao_tbk_dg_material_optional(keyword, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, '6707', $taobao_app_id_material, $taobao_app_secret_material, $taobao_adzone_id_material, page_no, 20 ))
  end

  def buy
    redirect_to "http://www.uuhaodian.com/yh/#{params[:id]}/#coupon", status: 302
  end

  def article
    meta = get_articles_meta
    if meta.size.zero?
      not_found
      return
    end
    sac = meta[:articles].select{|m| m[:id] == params[:id]}.first
    if sac.nil?
      not_found
      return
    end
    file = Rails.root.join("vendor/articles").join(sac[:file])
    html = Rails.root.join("vendor/articles").join("#{sac[:id]}.html")
    if !File.exists?(file) || !File.exists?(html)
      not_found
      return
    end
    f = File.read(file)
    content = f.split("######")
    @meta = YAML.load(content[0])[:article]
    @html = File.read(html)
  end

  def detail_x
    @coupon_money = params[:coupon_money].to_i
    url = "http://api.uuhaodian.com/uu/product?item_id=#{params[:id]}"
    json = {}
    @items = []
    begin
      result = Net::HTTP.get(URI(URI.encode(url)))
      json = JSON.parse(result)
      if json["status"]["code"] != 1001 || json["result"].nil?
        url = "http://api.uuhaodian.com/uu/product_tb?item_id=#{params[:id]}"
        result = Net::HTTP.get(URI(URI.encode(url)))
        json = JSON.parse(result)
        if json["status"] == 0 || json["result"].nil? || json["status"]["code"] != 1001
          not_found
          return
        end
      end
    rescue
      not_found
      return
    end
    @detail = json["result"]
    if !@coupon_money.nil? && @coupon_money > 0 && @detail["couponMoney"].to_i == 0
      @detail["couponMoney"] = @coupon_money
      price = @detail["nowPrice"]
      @detail["nowPrice"] = @detail["nowPrice"].to_f - @coupon_money
      @detail["price"] = price
    end
    if @detail["auctionImages"].size < 6
      @detail["auctionImages"].unshift(@detail["coverImage"])
    end
    if @detail.nil?
      not_found
      return
    end
    #@top_keywords = get_hot_keywords_data.sample(7)
    @path = "https://api.uuhaodian.com/uu/dg_goods_list"
    get_top_query
    @jiukuaijiu = get_coupon_9kuai9_data
    @cid3 = get_cid3_data
    if is_device_mobile?
      render "dazhe/detail_x", layout: "layouts/dazhe"
    else
      render "detail_x", layout: "layouts/diyquan"
    end
  end

  def buy_url_x
    if is_robot?
      render "not_found", status: 403
      return
    end
    url = "http://api.uuhaodian.com/uu/buy?id=#{params[:id]}&channel=16&xcx=1&short=1"
    json = {}
    begin
      result = Net::HTTP.get(URI(URI.encode(url)))
      url = result
      if url.empty?
        render json: {status: 1, id: params[:id], url: "http://m.uuhaodian.com"}, callback: params[:callback]
        return
      end
      render json: {status: 1, id: params[:id], url: url}, callback: params[:callback]
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def detail_y
    url = "http://api.uuhaodian.com/jduu/product?id=#{params[:id]}"
    json = {}
    @items = []
    begin
      result = Net::HTTP.get(URI(URI.encode(url)))
      json = JSON.parse(result)
      if json["status"] != 200
        not_found
        return
      end
    rescue
      not_found
      return
    end
    @detail = json["result"]
    if @detail.nil?
      not_found
      return
    end
    get_top_query
    @jiukuaijiu = get_coupon_9kuai9_data
    @cid3 = get_cid3_data
    if is_device_mobile?
      render "dazhe/detail_y", layout: "layouts/dazhe"
    else
      render "detail_y", layout: "layouts/diyquan"
    end
  end

  def buy_y
    if is_robot?
      render "not_found", status: 403
      return
    end
    if params[:id].to_i < 10 && params[:coupon]
      redirect_to params[:coupon], status: 302
      return
    end
    url = "http://api.uuhaodian.com/jduu/product_url?id=#{params[:id]}&jd_channel=5"
    if params[:coupon]
      url = "http://api.uuhaodian.com/jduu/product_url?id=#{params[:id]}&jd_channel=5&coupon=#{URI.encode_www_form_component(params[:coupon])}"
    end
    json = {}
    begin
      result = Net::HTTP.get(URI(URI.encode(url)))
      json = JSON.parse(result)
      if json["status"] != 200
        if params[:coupon]
          redirect_to "/buy/y_#{params[:id]}/"
          return
        end
        not_found
        return
      end
      redirect_to json["data"], status: 302
    rescue
      not_found
      return
    end
  end

  def buy_url_y
    if is_robot?
      render "not_found", status: 403
      return
    end
    if params[:id].to_i < 10 && params[:coupon]
      render json: {status: 1, id: params[:id], url: params[:coupon]}, callback: params[:callback]
      return
    end
    url = "http://api.uuhaodian.com/jduu/product_url?id=#{params[:id]}&jd_channel=11"
    if params[:coupon]
      url = "http://api.uuhaodian.com/jduu/product_url?id=#{params[:id]}&jd_channel=11&coupon=#{URI.encode_www_form_component(params[:coupon])}"
    end
    json = {}
    begin
      result = Net::HTTP.get(URI(URI.encode(url)))
      json = JSON.parse(result)
      if json["status"] != 200
        render json: {status: 1, id: params[:id], url: "https://item.jd.com/#{params[:id]}.html"}, callback: params[:callback]
        return
      end
      render json: {status: 1, id: params[:id], url: json["data"]}, callback: params[:callback]
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

  def detail_z
    url = "http://api.uuhaodian.com/ddk/product?id=#{params[:id]}"
    json = {}
    @items = []
    begin
      result = Net::HTTP.get(URI(URI.encode(url)))
      json = JSON.parse(result)
    rescue
      not_found
      return
    end
    @detail = json["result"]
    if @detail.nil?
      not_found
      return
    end
    if @detail["auctionImages"].size < 6
      @detail["auctionImages"].unshift(@detail["coverImage"])
    end
    @path = "https://api.uuhaodian.com/uu/dg_goods_list"
    get_top_query
    @jiukuaijiu = get_coupon_9kuai9_data
    @cid3 = get_cid3_data
    if is_device_mobile?
      render "dazhe/detail_z", layout: "layouts/dazhe"
    else
      render "detail_z", layout: "layouts/diyquan"
    end
  end

  def buy_z
    if is_robot?
      render "not_found", status: 403
      return
    end
    url = "http://api.uuhaodian.com/ddk/promotion_url?id=#{params[:id]}"
    json = {}
    begin
      result = Net::HTTP.get(URI(URI.encode(url)))
      json = JSON.parse(result)
      if json["status"] != 1
        not_found
        return
      end
      redirect_to json["result"]["we_app_web_view_short_url"], status: 302
    rescue
      not_found
      return
    end
  end

  def buy_url_z
    if is_robot?
      render "not_found", status: 403
      return
    end
    url = "http://api.uuhaodian.com/ddk/promotion_url?id=#{params[:id]}"
    json = {}
    begin
      result = Net::HTTP.get(URI(URI.encode(url)))
      json = JSON.parse(result)
      if json["status"] != 1
        render json: {status: 1, id: params[:id], url: "https://p.pinduoduo.com/61pQKH5i"}, callback: params[:callback]
        return
      end
      render json: {status: 1, id: params[:id], url: json["result"]["short_url"]}, callback: params[:callback]
    rescue
      render json: {status: 0}, callback: params[:callback]
    end
  end

end
