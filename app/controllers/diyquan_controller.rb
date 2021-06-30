class DiyquanController < ApplicationController
  include DiyquanHelper
  skip_before_action :verify_authenticity_token

  def zhekou
    return if redirect_pc_to_mobile
    zhekou_tdk
    @items = get_dg_items(@keyword)
    infos = get_dg_keyword_infos(@keyword)
    @keywords = infos && infos["r_keywords"] ? infos["r_keywords"] : []
    @cats = infos && infos["r_cats"] ? infos["r_cats"] : []
    @selectors = infos && infos["selector"] ? infos["selector"] : []
    rr = rand(10)
    @shops = get_jd_shops
    @sort_type = 0
    render "zhekou", layout: "layouts/diyquan"
  end

  def m_zhekou
    zhekou_tdk
    @items = get_dg_items(@keyword)
    infos = get_dg_keyword_infos(@keyword)
    @keywords = infos && infos["r_keywords"] ? infos["r_keywords"] : []
    #@cats = infos && infos["r_cats"] ? infos["r_cats"] : []
    @selectors = infos && infos["selector"] ? infos["selector"] : []
    @channel = 8
    render "m_diyquan/zhekou", layout: "layouts/m_diyquan"
  end

  def noresult
    @keyword = params[:keyword]
    @coupons = []
    @hot_keywords = get_hot_keywords
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
    render "page"
  end

  def m_page
    @page_info = Page.where(pinyin: params[:pinyin]).take
    not_found if @page_info.nil?
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
    @h1 = @page_info.anchor
    render "m_diyquan/page", layout: "layouts/m_diyquan"
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

  def friend_circle_list
    return if redirect_pc_to_mobile
    @page = params[:page].to_i
    @page = 0 if @page < 0
    @fcs = DtkFc.where("dtk_id <> -1").select(:id, :content, :updated_at).order("id desc").offset(20 * @page).limit(20)
    if @fcs.nil? || @fcs.size.zero?
      not_found
      return
    end
    @c = URI.decode(@fcs.first.content)
    @title = "朋友圈分享素材-优惠券代理-爱券网"
    @title = "#{@c.split("\n").first}-优惠券代理-第#{@page}页-爱券网" if @page > 0
    @description = @c.gsub("\n", "，") + " - 优惠券代理 - 爱券网"
    @page_keywords = "优惠券代理,爱券网"
    @h1 = ""
    @path = "/fc/"
    @pages = []
    (1..20).each do |n|
      @pages << @page + n if (@page + n < 610)
    end
    if request.host == "m.iquan.net"
      render "m_diyquan/friend_circle_list", layout: "layouts/m_diyquan"
      return
    end
  end

  def friend_circle_detail
    @id = params[:id].to_i
    if @id < 0
      not_found
      return
    end
    return if redirect_pc_to_mobile
    @fc = DtkFc.connection.execute("select c.id, c.dtk_id, c.content, p.dtitle, p.mainPic, p.monthSales, p.originalPrice, p.actualPrice, p.couponPrice, p.commissionRate, p.cnames, p.brandName, p.sellerId, p.shopName, c.updated_at, p.marketingMainPic
from dataoke_friend_circles c
join dataoke_products p on c.dtk_id = p.id
where c.id = #{@id} and c.dtk_id <> -1").to_a.map{|row|
      {
        id: row[0],
        dtk_id: row[1],
        content: row[2],
        title: row[3],
        mainPic: row[4],
        sales: row[5],
        op: row[6],
        ap: row[7],
        cp: row[8],
        rate: row[9],
        cnames: row[10],
        brand: row[11],
        shop_id: row[12],
        shop_name: row[13],
        time: row[14],
        mPic: row[15]
      }
    }
    if @fc.size.zero?
      not_found
      return
    end
    @fc = @fc.first
    @c = URI.decode(@fc[:content])
    @fcs = DtkFc.where("dtk_id <> -1 and id > ?", @id).select(:id, :content, :updated_at).order(:id).limit(10)
    @title = "#{@c.split("\n").first}-爱券网"
    @description = @c.gsub("\n", "，") + " - 爱券网"
    @page_keywords = @fc[:cnames]
    @h1 = @c.split("\n").first
    @path = "/fc/#{@id}/"
    if request.host == "m.iquan.net"
      render "m_diyquan/friend_circle_detail", layout: "layouts/m_diyquan"
      return
    end
    @items = DtkProduct.where(status: 1).select(:id, :mainPic, :dtitle, :originalPrice, :actualPrice, :couponPrice, :monthSales, :shopType).order("id desc").limit(10)
  end

  def dataoke_product
    @d = DtkProduct.where(id: params[:id].to_i).take
    if @d.nil?
      not_found
      return
    end
    img = DtkProductImg.where(product_id: @d.id).take
    @imgs = img.nil? ? [@d.mainPic] : img.imgs.split(',')
    @details = img.nil? ? @imgs : img.details.empty? ? @imgs : JSON.parse(img.details).map{|x| x["img"]}
    @news = DtkProduct.select(:id, :dtitle, :actualPrice, :mainPic).order("id desc").limit(10)
    @related = DtkProduct.where(cid: @d.cid, status: [0,1]).select(:id, :dtitle, :actualPrice, :mainPic, :shopName).limit(10)
    @shops = @related.map{|r| r.shopName}.uniq
    @youhui = JSON.parse(@d.specialText).first
    @youhui = "可领#{@d["couponPrice"]}元优惠券" if @youhui.nil?
  end

end
