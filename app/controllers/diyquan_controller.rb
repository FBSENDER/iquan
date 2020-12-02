class DiyquanController < ApplicationController
  include DiyquanHelper
  skip_before_action :verify_authenticity_token

  def zhekou
    return if redirect_pc_to_mobile
    zhekou_tdk
    sort_type = 0
    @items = get_dg_items(@keyword)
    infos = get_dg_keyword_infos(@keyword)
    @keywords = infos && infos["r_keywords"] ? infos["r_keywords"] : []
    @cats = infos && infos["r_cats"] ? infos["r_cats"] : []
    @selectors = infos && infos["selector"] ? infos["selector"] : []
    rr = rand(10)
    @shops = get_jd_shops
    @sort_type = sort_type
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
