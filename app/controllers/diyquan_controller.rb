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
        redirect_to "http://m.uuhaodian.com/index.php?r=index%2Fsearch&s_type=0&kw=#{URI.encode_www_form_component(@keyword)}&from=m_shikuai", status: 302
      else
        redirect_to "http://www.uuhaodian.com/query/#{URI.encode_www_form_component(@keyword)}/?from=shikuai", status: 302
      end
      return
    end
    @zhekous = []
    data  = get_tbk_search_json(@keyword, 1)
    if(data["tbk_item_get_response"] && data["tbk_item_get_response"]["total_results"] > 0)
      @zhekous = data["tbk_item_get_response"]["results"]["n_tbk_item"]
    end
    if is_robot?
      render "diyquan/fenlei", layout: "layouts/diyquan"
    else
      render "diyquan/lanlan_fenlei", layout: "layouts/diyquan"
    end
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
    unless is_robot?
      if is_device_mobile?
        s_type = is_taobao_title?(@keyword) ? 1 : 0
        #redirect_to "http://m.uuhaodian.com/index.php?r=index%2Fsearch&s_type=#{s_type}&kw=#{URI.encode_www_form_component(@keyword)}&from=m_shikuai", status: 302
        redirect_to "http://www.uuhaodian.com/dz/#{URI.encode_www_form_component(@keyword)}/?from=m_shikuai", status: 302
      else
        redirect_to "http://www.uuhaodian.com/query/#{URI.encode_www_form_component(@keyword)}/?from=shikuai", status: 302
      end
      return
    else
      @coupons = []
      @zhekous = []
      data  = get_tbk_search_json(@keyword, 1)
      if(data["tbk_item_get_response"] && data["tbk_item_get_response"]["total_results"] > 0)
        @zhekous = data["tbk_item_get_response"]["results"]["n_tbk_item"]
      end
      @shops = []
      @sort_type = sort_type
    end
    @keywords = ZhekouKeyword.where(keyword: @keyword).pluck(:word)
    @path = request.path + "/"
    if is_device_mobile?
      render "m_diyquan/zhekou", layout: "layouts/m_diyquan"
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
    redirect_to "http://u.58pu.net.cn/x/9dcb8d5a", status: 302
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
    JSON.parse(tbk.taobao_tbk_item_get(keyword, $taobao_app_id, $taobao_app_secret, page_no + 1,50))
  end

  def buy
    redirect_to "http://www.uuhaodian.com/yh/#{params[:id]}/#coupon", status: 302
  end

end
