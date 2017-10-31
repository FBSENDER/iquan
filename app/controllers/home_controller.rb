require 'seo_domain'
require 'iquan'
require 'net/http'
class HomeController < ApplicationController
  @@compete_brands = nil
  @@product_brands = nil
  def index
    if request.host == "www.17430.com.cn" && is_device_mobile?
      redirect_to "http://m.17430.com.cn", status: 302
      return
    end
    if !is_robot? 
      if is_device_mobile?
        m_diyquan_home
        #redirect_to "http://taobao.iquan.net", status: 302
        #redirect_to "http://taobao", status: 302
        #redirect_to "http://iquan.zhequan.cc", status: 302
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
  end

  def diyquan_home
    url = "http://z.17gwx.com/web/index/index?client_id=zhekou_app_h5&client_secret=81f454ac98956541b195f2c7f9e53a06&page=0&pagesize=20"
    @coupons = JSON.parse(Net::HTTP.get(URI(url)))["data"]["coupon_list"]
    @links = Link.where(status: 1).to_a
    render "diyquan/home", layout: "layouts/diyquan"
  end

  def m_diyquan_home
    url = "http://z.17gwx.com/web/index/index?client_id=zhekou_app_h5&client_secret=81f454ac98956541b195f2c7f9e53a06&page=0&pagesize=20"
    @coupons = JSON.parse(Net::HTTP.get(URI(url)))["data"]["coupon_list"]
    render "m_diyquan/home", layout: "layouts/m_diyquan"
  end
end
