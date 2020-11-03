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
    unless is_robot?
      if is_device_mobile?
        redirect_to "http://m.uuhaodian.com/index.php?r=index/classify&hot=2&kw=#{URI.encode_www_form_component(@keyword)}&from=m_iquan", status: 302
      else
        redirect_to "http://www.uuhaodian.com/query/#{URI.encode_www_form_component(@keyword)}/?from=iquan", status: 302
      end
      return
    else
      @coupons = []
      @zhekous = []
      data  = get_tbk_search_json(@keyword, 1)
      if(data["tbk_item_get_response"] && data["tbk_item_get_response"]["total_results"] > 0)
        @zhekous = data["tbk_item_get_response"]["results"]["n_tbk_item"]
      end

      if is_device_mobile?
        render "m_diyquan/fenlei", layout: "layouts/m_diyquan"
      else
        render "diyquan/fenlei", layout: "layouts/diyquan"
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
    if is_keyword_url?(@keyword)
      id = get_tb_id(@keyword)
      if id
        redirect_to "http://api.uuhaodian.com/uu/buy?id=#{id}&channel=2", status: 302
        log = SearchUrlLog.new
        log.item_id = id.to_i
        log.save
      else
        redirect_to "/query/noresult/?keyword=#{URI.encode(@keyword)}", status: 302
      end
      return
    end
    
    unless is_robot?
      if is_device_mobile?
        s_type = is_taobao_title?(@keyword) ? 1 : 0
        redirect_to "http://m.uuhaodian.com/index.php?r=index/classify&hot=2&kw=#{URI.encode_www_form_component(@keyword)}&from=m_iquan", status: 302
      else
        redirect_to "http://www.uuhaodian.com/query/#{URI.encode_www_form_component(@keyword)}/?from=iquan", status: 302
      end
      return
    else
      @items = get_dg_items(@keyword)
      infos = get_dg_keyword_infos(@keyword)
      @keywords = infos && infos["r_keywords"] ? infos["r_keywords"] : []
      @cats = infos && infos["r_cats"] ? infos["r_cats"] : []
      @selectors = infos && infos["selector"] ? infos["selector"] : []
      rr = rand(10)
      @shops = get_jd_shops
      @sort_type = sort_type
    end
    @path = request.path + "/"
    if is_device_mobile?
      render "m_diyquan/zhekou", layout: "layouts/m_diyquan"
    else
      render "zhekou", layout: "layouts/diyquan"
    end
  end

  def noresult
    @keyword = params[:keyword]
    @coupons = []
    @hot_keywords = get_hot_keywords
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
      redirect_to "https://www.iquan.net", status: 301
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
      @related_coupons = []
      @same_seller_coupons = []
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

  def lanlan_download
    redirect_to "http://uuhaodian.com/index.php?r=app/download&u=550416", status: 302
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
    unless is_robot?
      if is_device_mobile?
        redirect_to "http://m.uuhaodian.com/index.php?r=index/classify&hot=2&kw=#{URI.encode_www_form_component(@page_info.search_keyword)}&from=m_iquan", status: 302
      #else
      #  redirect_to "http://www.uuhaodian.com/query/#{URI.encode_www_form_component(@page_info.search_keyword)}/?from=iquan", status: 302
      #end
        return
      end
    end
    @title = @page_info.title
    @description = @page_info.description
    @desc_ext = @page_info.desc_ext
    @page_info.core_keywords.split(',').each do |k|
      @desc_ext = @desc_ext.gsub(k, "<strong>#{k}</strong>")
    end
    @items = get_dg_items(@page_info.search_keyword)
    @keywords = @page_info.keywords
    @search_keyword = @page_info.search_keyword
    @suggest_keywords = get_suggest_keywords_new(@page_info.search_keyword)
    @path = request.path + "/"
    @seo_k = @page_info.search_keyword 
    @keyword = @page_info.search_keyword 
    @links = Page.select(:anchor, :url)
    @outlinks = OutLink.where(url: request.url).select(:keyword, :outurl)
    @h1 = @page_info.anchor
    @shops = get_jd_shops
    if is_device_mobile?
      render "m_diyquan/page", layout: "layouts/m_diyquan"
    else
      render "page"
    end
  end

  def k_pinyin
    return if redirect_pc_to_mobile
    @tag = Tag.where(pinyin: params[:pinyin]).take
    not_found if @tag.nil?
    k_pinyin_tdk
    @items = get_dg_items(@keyword)
    infos = get_dg_keyword_infos(@keyword)
    @keywords = infos && infos["r_keywords"] ? infos["r_keywords"] : []
    @cats = infos && infos["r_cats"] ? infos["r_cats"] : []
    @selectors = infos && infos["selector"] ? infos["selector"] : []
    #@shops = Shop.where(source_id: @items.map{|c| c["seller_id"]}.uniq).select(:title, :nick)
    if is_device_mobile?
      render "m_diyquan/zhekou", layout: "layouts/m_diyquan"
    else
      render "zhekou", layout: "layouts/diyquan"
    end
  end

  def map_k
    @page = params[:page].to_i
    @page = @page == 0 ? 0 : @page - 1
    @ks = TbKeyword.where(status: 1).select(:id, :keyword).order(:id).limit(500).offset(500 * @page)
    #@total_page = 900
    pg = @page + 2
    @pages = []
    loop do
      break if pg > 916 || @pages.size > 20 
      @pages << pg 
      pg += 1
    end
    not_found if @ks.size.zero?
    map_k_tdk
  end

end
