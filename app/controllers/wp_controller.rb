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
    @desc += "特价折扣平台-17430.com.cn"
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
  end

end
