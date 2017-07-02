require 'seo_domain'
require 'net/http'
class HomeController < ApplicationController
  @@compete_brands = nil
  def index
    if request.host == "www.ichaopai.cc"
      render "ichaopai"
      return
    end
    if !is_robot? && request.host != "www.zhequan.cc"
      if is_device_mobile?
        redirect_to "http://taobao.iquan.net", status: 302
      else
        diyquan_home
      end
      return
    end
    if @@compete_brands.nil? || Time.now.to_i % 600 == 0
      @@compete_brands = CompeteBrand.select(:title, :keywords, :description, :host).to_a
    end
    @compete_brands = @@compete_brands
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
  end

  def diyquan_home
    url = "http://z.17gwx.com/web/index/index?client_id=zhekou_app_h5&client_secret=81f454ac98956541b195f2c7f9e53a06&page=0&pagesize=40"
    @coupons = JSON.parse(Net::HTTP.get(URI(url)))["data"]["coupon_list"]
    render "diyquan/home", layout: "layouts/diyquan"
  end
end
