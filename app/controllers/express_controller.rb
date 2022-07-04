require 'net/http'
require 'express'
require 'express_config'

class ExpressController < ApplicationController
  layout "express_pc"

  $hot_keywords = AliKeyword.where(is_hot: 1).pluck(:keyword)
  $rank_keywords = AliKeyword.where(is_rank: 1).pluck(:keyword)
  $new_arrival_data = {}

  def get_new_arrival_data
    begin
      if $new_arrival_data["update_at"].nil? || $new_arrival_data["items"].nil? || $new_arrival_data["items"].size.zero? || Time.now.to_i - $new_arrival_data["update_at"] > 60
        json = JSON.parse(aliexpress_affiliate_product_query($api_key, $secret, "New Arrival", "66", "", 1, 20))
        if json["aliexpress_affiliate_product_query_response"]["resp_result"]["resp_code"] == 200
          $new_arrival_data["items"] = json["aliexpress_affiliate_product_query_response"]["resp_result"]["result"]["products"]["product"]
          $new_arrival_data["update_at"] = Time.now.to_i
          return $new_arrival_data["items"]
        else
          return []
        end
      end
      return $new_arrival_data["items"]
    rescue
      return []
    end
  end

  def home
    @k = ""
    @top_nav = 1
    @cate1 = AliCategory.where(parent_id: 0).select(:id, :name).order(:id)
    @brands = AliBrand.select(:id, :name, :img_url).take(16)
    @hot_keywords = $hot_keywords.sample(10)
    @rank_keywords = $rank_keywords.sample(10)
    @top_query = $hot_keywords.sample(5)
    if is_device_mobile?
      render "express_mobile/home", layout: "layouts/express_mobile"
      return
    end
  end

  def ec
    @top_nav = 0
    @category = AliCategory.where(id: params[:id].to_i).take
    not_found if @category.nil?
    @k = @category.name
    @search_k = @category.level == 1 ? "" : @k.split('&')[0].strip.gsub("'", "")  
    @nav = JSON.parse(@category.nav)
    @cate1 = AliCategory.where(parent_id: 0).select(:id, :name).order(:id)
    @same_level_cate = @category.level >= 2 ? AliCategory.where(parent_id: @category.parent_id).select(:id, :name).order(:id) : []
    @categories = AliCategory.where(parent_id: @category.source_id).select(:id, :name)
    bids = AliCB.where(category_id: @category.id).pluck(:brand_id)
    @brands = bids.size.zero? ? [] : AliBrand.where(id: bids).select(:id, :name, :img_url)
    kids = AliCK.where(category_id: @category.id).pluck(:keyword_id)
    @keywords = AliKeyword.where(id: kids, is_hot: 0, is_rank: 0).pluck(:keyword)
    @hot_keywords = $hot_keywords.sample(10)
    @rank_keywords = $rank_keywords.sample(10)
    @top_query = $hot_keywords.sample(5)
    ar = AliCategoryAttr.where(category_id: @category.id).take
    if ar.nil? || ar.attr_json.empty?
      @attr = []
    else
      @attr = JSON.parse(ar.attr_json) 
    end
    if is_device_mobile?
      render "express_mobile/ec", layout: "layouts/express_mobile"
      return
    end
  end

  def eb
    @top_nav = 0
    @brand = AliBrand.where(id: params[:id].to_i).take
    not_found if @brand.nil?
    @k = @brand.name
    cids = AliCB.where(brand_id: @brand.id).pluck(:category_id)
    @categories = AliCategory.where(id: cids).select(:id, :name).sample(10)
    bids = AliCB.where("category_id in (?) and brand_id <> ?", @categories.map{|c| c.id}, @brand.id).limit(16).pluck(:brand_id)
    @brands = AliBrand.where(id: bids).select(:id, :name, :img_url)
    @hot_keywords = $hot_keywords.sample(10)
    @rank_keywords = $rank_keywords.sample(10)
    @top_query = $hot_keywords.sample(5)
    if is_device_mobile?
      render "express_mobile/eb", layout: "layouts/express_mobile"
      return
    end
  end

  def e_promo
    @k = params[:keyword].strip
    not_found unless ['Hot Product','New Arrival','Best Seller','Weekly Deal'].include?(@k)
    if @k == "Hot Product"
      @top_nav = 2
    elsif @k == "New Arrival"
      @top_nav = 3
    elsif @k == "Best Seller"
      @top_nav = 4
    else
      @top_nav = 5
    end
    @category_id = params[:category].nil? ? 0 : params[:category].to_i
    @category = AliCategory.where(id: @category_id).take
    @hot_keywords = $hot_keywords.sample(10)
    @rank_keywords = $rank_keywords.sample(10)
    @top_query = $hot_keywords.sample(5)
    @keyword = AliKeyword.where(keyword: @k).take
    @sort_id = 1
    @cate1 = AliCategory.where(parent_id: 0).select(:id, :name, :cid).order(:id)
    @keywords = []
    if is_device_mobile?
      render "express_mobile/e_promo", layout: "layouts/express_mobile"
      return
    end
  end

  def ecb
    @top_nav = 0
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
    file = Rails.root.join("public/express_jsons/category_brand").join("ecb_#{@category.id}_#{@brand.id}.json")
    if File.exists?(file)
      @items = JSON.parse(File.read(file))
    else
      @items = get_items(@brand.name.gsub("&", " ") + " " + @category.name.gsub("&", ""), @category.cid > 0 ? @category.cid.to_s : "")
      @items = get_items(@brand.name.gsub("&", " "), "") if @items.size.zero?
      @items = get_items("hot promotions", "") if @items.size.zero?
    end
    ar = AliCategoryAttr.where(category_id: @category.id).take
    if ar.nil? || ar.attr_json.empty?
      @attr = []
    else
      @attr = JSON.parse(ar.attr_json) 
    end
  end

  def deal_keyword_request
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
    file = Rails.root.join("public/express_jsons/keyword").join("ek_#{@keyword.id}.json")
    if File.exists?(file)
      @items = JSON.parse(File.read(file))
    else
      @items = get_items(@keyword.keyword.gsub("&", ""), @keyword.is_hot == 0 && @keyword.is_rank == 0 && @category.cid > 0 ? @category.cid.to_s : "")
      @items = get_items(@keyword.keyword.gsub("&", ""), "") if @items.size.zero?
      if @items.size > 0
        File.open(file, "w") do |f|
          f.puts @items.to_json
        end
      end
      @items = get_items(@k.split.first, "") if @items.size.zero?
    end
  end

  def ek
    @top_nav = 0
    not_found if params[:keyword].nil?
    @k = params[:keyword].strip
    @hot_keywords = $hot_keywords.sample(10)
    @rank_keywords = $rank_keywords.sample(10)
    @top_query = $hot_keywords.sample(5)
    @keyword = AliKeyword.where(keyword: @k).take
    @sort_id = 1
    if @keyword.nil?
      @nav = []
      @category = nil
      @keywords = []
    else
      r = AliCK.where(keyword_id: @keyword.id).take
      not_found if r.nil?
      @category = AliCategory.where(id: r.category_id).take
      not_found if @category.nil?
      @nav = JSON.parse(@category.nav)
      kids = AliCK.where(category_id: @category.id).pluck(:keyword_id)
      @keywords = AliKeyword.where(id: kids).select(:keyword, :is_hot, :is_rank)
    end
    if is_device_mobile?
      render "express_mobile/ek", layout: "layouts/express_mobile"
      return
    end
  end

  def e_popular
    @top_nav = 0
    not_found if params[:keyword].nil?
    @k = params[:keyword].strip
    @hot_keywords = $hot_keywords.sample(10)
    @rank_keywords = $rank_keywords.sample(10)
    @top_query = $hot_keywords.sample(5)
    @keyword = AliKeyword.where(keyword: @k).take
    @sort_id = 2
    if @keyword.nil?
      @nav = []
      @category = nil
      @keywords = []
    else
      r = AliCK.where(keyword_id: @keyword.id).take
      not_found if r.nil?
      @category = AliCategory.where(id: r.category_id).take
      not_found if @category.nil?
      @nav = JSON.parse(@category.nav)
      kids = AliCK.where(category_id: @category.id).pluck(:keyword_id)
      @keywords = AliKeyword.where(id: kids).select(:keyword, :is_hot, :is_rank)
    end
    @ss_id = 2
    if is_device_mobile?
      render "express_mobile/e_popular", layout: "layouts/express_mobile"
      return
    end
  end

  def e_detail
    @top_nav = 0
    @id = params[:id].to_i
    not_found if @id <= 0
    j = JSON.parse(aliexpress_affiliate_productdetail_get($api_key, $secret, @id))
    data = j["aliexpress_affiliate_productdetail_get_response"]
    if data["resp_result"]["resp_code"] != 200 || data["resp_result"]["result"].nil?
      not_found
    end
    begin
      @detail = data["resp_result"]["result"]["products"]["product"][0]
      @new_arrival = get_new_arrival_data
      @cate1 = AliCategory.where(source_id: @detail["first_level_category_id"]).take
      @cate2 = AliCategory.where(source_id: @detail["second_level_category_id"]).take
      @k = 'Hot Product'
      if @cate1
        bids = AliCB.where(category_id: @cate1.id).pluck(:brand_id)
        @brands = bids.size.zero? ? [] : AliBrand.where(id: bids).select(:id, :name, :img_url).limit(20)
      else
        @brands = []
      end
      @top_query = $hot_keywords.sample(5)
    rescue
      not_found
    end
    if is_device_mobile?
      render "express_mobile/e_detail", layout: "layouts/express_mobile"
      return
    end
    
    #link = get_product_link(params[:id])
    #if link.empty?
    #  redirect_to "https://s.click.aliexpress.com/e/_pI8RUci", status: 302
    #else
    #  redirect_to link, status: 302
    #end
  end

  def e_promo_query
    page = params[:page].nil? ? 1 : params[:page].to_i
    promo_name = params[:promo_name].nil? ? "Hot Product" : params[:promo_name].strip.to_s
    category = params[:category].nil? ? "" :  params[:category].strip.to_s
    sort = params[:sort].nil? ? "" : params[:sort].to_s
    j = JSON.parse(aliexpress_affiliate_product_query($api_key, $secret, promo_name, category, sort, page, 20))
    render json: j, callback: params[:callback]
  end

  def e_query
    page = params[:page].nil? ? 1 : params[:page].to_i
    keyword = params[:keyword].nil? ? "" : params[:keyword].strip.to_s
    category = params[:category].nil? ? "" :  params[:category].strip.to_s
    sort = params[:sort].nil? ? "" : params[:sort].to_s
    j = JSON.parse(aliexpress_affiliate_product_query($api_key, $secret, keyword, category, sort, page, 20))
    render json: j, callback: params[:callback]
  end

  def e_shop_x_buy
    shop_id = params[:id]
    link = get_affiliate_link("https://www.aliexpress.com/store/#{shop_id}")
    if link.empty?
      redirect_to "https://s.click.aliexpress.com/e/_pI8RUci", status: 302
    else
      redirect_to link, status: 302
    end
  end

end
