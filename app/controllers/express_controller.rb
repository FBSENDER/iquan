require 'net/http'
require 'express'
require 'express_config'

class ExpressController < ApplicationController
  layout "express"

  $hot_keywords = AliKeyword.where(is_hot: 1).pluck(:keyword)
  $rank_keywords = AliKeyword.where(is_rank: 1).pluck(:keyword)

  def home
    @k = ""
    @categories = AliCategory.where(level: 1, status: 1).select(:id, :name)
    @hot_keywords = $hot_keywords.sample(10)
    @rank_keywords = $rank_keywords.sample(10)
    @items = get_items("hot promotions", "")
  end

  def ec
    @category = AliCategory.where(id: params[:id].to_i).take
    not_found if @category.nil?
    @k = @category.name
    @nav = JSON.parse(@category.nav)
    @categories = AliCategory.where(parent_id: @category.source_id).select(:id, :name)
    bids = AliCB.where(category_id: @category.id).pluck(:brand_id)
    @brands = bids.size.zero? ? [] : AliBrand.where(id: bids).select(:id, :name, :img_url)
    kids = AliCK.where(category_id: @category.id).pluck(:keyword_id)
    @keywords = AliKeyword.where(id: kids, is_hot: 0, is_rank: 0).pluck(:keyword)
    @hot_keywords = $hot_keywords.sample(10)
    @rank_keywords = $rank_keywords.sample(10)
    @items = get_items(@category.name.gsub("&", ""), @category.cid > 0 ? @category.cid.to_s : "")
    ar = AliCategoryAttr.where(category_id: @category.id).take
    if ar.nil? || ar.attr_json.empty?
      @attr = []
    else
      @attr = JSON.parse(ar.attr_json) 
    end
  end

  def eb
    @brand = AliBrand.where(id: params[:id].to_i).take
    not_found if @brand.nil?
    @k = @brand.name
    cids = AliCB.where(brand_id: @brand.id).pluck(:category_id)
    @categories = AliCategory.where(id: cids).select(:id, :name)
    bids = AliCB.where("category_id in (?) and brand_id <> ?", cids, @brand.id).pluck(:brand_id)
    @brands = AliBrand.where(id: bids).select(:id, :name, :img_url)
    @hot_keywords = $hot_keywords.sample(10)
    @rank_keywords = $rank_keywords.sample(10)
    @items = get_items(@brand.name.gsub("&", " "), "")
  end

  def ecb
    r = AliCB.where(category_id: params[:cid].to_i, brand_id: params[:bid].to_i).take
    not_found if r.nil?
    @category = AliCategory.where(id: params[:cid].to_i).take
    not_found if @category.nil?
    @brand = AliBrand.where(id: params[:bid].to_i).take
    not_found if @brand.nil?
    @k = "#{@brand.name} #{@category.name}"
    @nav = JSON.parse(@category.nav)
    kids = AliCK.where(category_id: @category.id).pluck(:keyword_id)
    @keywords = AliKeyword.where(id: kids, is_hot: 0, is_rank: 0).pluck(:keyword)
    @hot_keywords = $hot_keywords.sample(10)
    @rank_keywords = $rank_keywords.sample(10)
    @items = get_items(@brand.name.gsub("&", " ") + " " + @category.name.gsub("&", ""), @category.cid > 0 ? @category.cid.to_s : "")
    @items = get_items(@brand.name.gsub("&", " "), "") if @items.size.zero?
    ar = AliCategoryAttr.where(category_id: @category.id).take
    if ar.nil? || ar.attr_json.empty?
      @attr = []
    else
      @attr = JSON.parse(ar.attr_json) 
    end
  end

  def ek
    @keyword = AliKeyword.where(keyword: params[:keyword]).take
    not_found if @keyword.nil?
    @k = @keyword.keyword
    r = AliCK.where(keyword_id: @keyword.id).take
    not_found if r.nil?
    @category = AliCategory.where(id: r.category_id).take
    not_found if @category.nil?
    @nav = JSON.parse(@category.nav)
    kids = AliCK.where(category_id: @category.id).pluck(:keyword_id)
    @keywords = AliKeyword.where(id: kids).select(:keyword, :is_hot, :is_rank)
    @hot_keywords = $hot_keywords.sample(10)
    @rank_keywords = $rank_keywords.sample(10)
    @items = get_items(@keyword.keyword.gsub("&", ""), @keyword.is_hot == 0 && @keyword.is_rank == 0 && @category.cid > 0 ? @category.cid.to_s : "")
    @items = get_items(@keyword.keyword.gsub("&", ""), "") if @items.size.zero?
  end

  def e_detail
    if is_robot?
      render plain: "", status: 403
      return
    end
    link = get_product_link(params[:id])
    if link.empty?
      redirect_to "https://s.click.aliexpress.com/e/_pI8RUci", status: 302
    else
      redirect_to link, status: 302
    end
  end

end
