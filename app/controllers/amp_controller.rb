class AmpController < ApplicationController
  include DiyquanHelper
  def zhekou
    @keyword = params[:keyword].force_encoding('utf-8')
    zhekou_tdk
    @path = "/zhekou/#{URI.encode(@keyword)}/"
    @links = []
    @keyword = params[:keyword].strip
    @items = get_dg_items(@keyword)
    infos = get_dg_keyword_infos(@keyword)
    @keywords = infos && infos["r_keywords"] ? infos["r_keywords"] : []
    @cats = infos && infos["r_cats"] ? infos["r_cats"] : []
    @selectors = infos && infos["selector"] ? infos["selector"] : []
    @shops = []
    render "amp/zhekou", layout: "layouts/amp_diyquan"
  end

  def page
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
    @path = "/g_#{params[:pinyin]}/"
    @seo_k = @page_info.search_keyword 
    @keyword = @page_info.search_keyword 
    @h1 = @page_info.anchor
    render "amp/page", layout: "layouts/amp_diyquan"
  end

  def k_pinyin
    @tag = Tag.where(pinyin: params[:pinyin]).take
    not_found if @tag.nil?
    k_pinyin_tdk
    @items = get_dg_items(@keyword)
    infos = get_dg_keyword_infos(@keyword)
    @keywords = infos && infos["r_keywords"] ? infos["r_keywords"] : []
    @cats = infos && infos["r_cats"] ? infos["r_cats"] : []
    @selectors = infos && infos["selector"] ? infos["selector"] : []
    @path = "/k_#{params[:pinyin]}"
    render "amp/k_pinyin", layout: "layouts/amp_diyquan"
  end
end
