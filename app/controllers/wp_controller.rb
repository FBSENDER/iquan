require 'wp'
require 'net/http'

class WpController < ApplicationController
  layout "17430"

  def wp
    k = ComKeyword.where(id: params[:id].to_i).take
    not_found if k.nil?
    url = "http://api.uuhaodian.com/uu/dg_seo_goods_list?keyword=#{k.keyword}"
    result = Net::HTTP.get(URI(URI.encode(url)))
    data = JSON.parse(result)
    @k = k.keyword
    @id = k.id
    @ks = ComKeyword.where(id: k.r_keywords.split(',')).select(:id, :keyword)
    @ss = ComShop.where(id: k.r_shops.split(',')).select(:id, :nick)
    @base = k.base_words.split
    @desc = "便宜网购商城为您提供#{@k}信息查询服务，包括#{@k}价格、#{@k}图片、#{@k}品牌、#{@k}包邮以及#{@k}优惠券。"
    if data["status"] == 1
      @products = data["results"]
      if @products.size > 3
        @desc += "为您推荐"
        @desc += "#{@products[0]["title"]} #{@products[0]["zk_final_price"]}元，"
        @desc += "#{@products[1]["title"]} #{@products[1]["zk_final_price"]}元，"
        @desc += "#{@products[2]["title"]} #{@products[2]["zk_final_price"]}元。"
      end
    else
      @products = []
    end
    @ds = Detail.select(:id, :title, :description, :pic).order("id desc").limit(10)
    @desc += "特价折扣平台-17430.com.cn"
    @robot = is_robot?
    @selector = []
    if @robot
      s = Selector.where(keyword: @k).take
      if s
        @selector = JSON.parse(s.selector)
      end
    end
  end

  def ws
    s = ComShop.where(id: params[:id].to_i).take
    not_found if s.nil?
    @shop = Shop.where(source_id: s.source_id).take
    not_found if @shop.nil?
    @id = s.id
    @ks = ComKeyword.where(id: s.r_keywords.split(',')).select(:id, :keyword)
    @ss = ComShop.where(id: s.r_shops.split(',')).select(:id, :nick)
    @s = s
    @desc = "便宜网购商城为您提供#{@s.nick}信息查询服务，包括#{@s.nick}首页网址、#{@s.nick}用户评价、#{@s.nick}优惠券以及#{@s.nick}折扣商品，特价折扣平台-17430.com.cn"
    @ds = Detail.select(:id, :title, :description, :pic).order("id desc").limit(10)
  end

  def wd
    @d = Detail.where(id: params[:id].to_i).take
    not_found if @d.nil?
    @products = DtkProduct.where(id: @d.product_ids.split(',')).select(:id, :goodsId, :dtitle, :desc, :originalPrice, :actualPrice, :discounts, :couponPrice, :couponEndTime, :monthSales, :sellerId, :shopName).order(:sellerId)
    @pds = []
    @products.map{|x| x.shopName}.uniq.each do |n|
      @pds << [n, @products.select{|x| x.shopName == n}]
    end
    @ds = Detail.select(:id, :title, :description, :pic).order("id desc").limit(10)
  end

  def wb
    @ds = Detail.where(brand_id: params[:id].to_i).select(:id, :brand_name, :title, :description, :pic).order("id desc")
    not_found if @ds.size.zero?
    @brand_id = params[:id].to_i
    @brand_name = @ds.first.brand_name
  end

end
