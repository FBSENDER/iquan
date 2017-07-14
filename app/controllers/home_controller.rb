require 'seo_domain'
require 'net/http'
class HomeController < ApplicationController
  @@compete_brands = nil
  @@product_brands = nil
  def index
    if request.host == "www.ichaopai.cc"
      render "ichaopai"
      return
    end
    if !is_robot? && request.host.include?("pinpai.iquan.net")
      brand = ProductBrand.where(host: request.host, status: 1).select(:search_keyword).take
      not_found if brand.nil?
      redirect_to "http://www.iquan.net/zhekou/#{URI.encode(brand.search_keyword)}/", status: 302
      return
    end
    if !is_robot? && request.host != "www.zhequan.cc"
      if is_device_mobile?
        m_diyquan_home
        #redirect_to "http://taobao.iquan.net", status: 302
      else
        diyquan_home
      end
      return
    end
    if @@compete_brands.nil? || Time.now.to_i % 600 == 0
      @@compete_brands = CompeteBrand.select(:title, :keywords, :description, :host).to_a
    end
    if @@product_brands.nil? || Time.now.to_i % 610 == 0
      @@product_brands = ProductBrand.where(status: 1).select(:title, :keywords, :host, :comments).to_a
    end
    @compete_brands = @@compete_brands
    @product_brands = @@product_brands
    @path = "/"
    if request.host == "www.zhequan.cc"
      render "zhequan"
      return
    end
    if request.host.include?(".youhui.iquan.net")
      brand = CompeteBrand.where(host: request.host).take
      not_found if brand.nil?
      @title = brand.title
      @keywords = brand.keywords
      @description = brand.description
    end
    if request.host.include?(".pinpai.iquan.net")
      brand = ProductBrand.where(host: request.host).take
      not_found if brand.nil?
      @title = brand.title
      @keywords = brand.keywords
      @description = brand.description
      @comments = brand.comments
    end
  end

  def diyquan_home
    url = "http://z.17gwx.com/web/index/index?client_id=zhekou_app_h5&client_secret=81f454ac98956541b195f2c7f9e53a06&page=0&pagesize=20"
    @coupons = JSON.parse(Net::HTTP.get(URI(url)))["data"]["coupon_list"]
    render "diyquan/home", layout: "layouts/diyquan"
  end

  def m_diyquan_home
    url = "http://z.17gwx.com/web/index/index?client_id=zhekou_app_h5&client_secret=81f454ac98956541b195f2c7f9e53a06&page=0&pagesize=20"
    @coupons = JSON.parse(Net::HTTP.get(URI(url)))["data"]["coupon_list"]
    render "m_diyquan/home", layout: "layouts/m_diyquan"
  end
end
