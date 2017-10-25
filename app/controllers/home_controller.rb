require 'seo_domain'
require 'iquan'
require 'net/http'
class HomeController < ApplicationController
  @@compete_brands = nil
  @@product_brands = nil
  def index
    if request.host == "www.ichaopai.cc"
      render "ichaopai"
      return
    end
    if request.host == "www.iquan.net" && is_device_mobile?
      redirect_to "http://m.iquan.net", status: 302
      return
    end
    if !is_robot? && request.host.include?("pinpai.iquan.net")
      brand = ProductBrand.where(host: request.host, status: 1).select(:search_keyword).take
      not_found if brand.nil?
      redirect_to "http://www.iquan.net/zhekou/#{URI.encode(brand.search_keyword)}/", status: 302
      return
    end
    if !is_robot? 
      if is_device_mobile?
        m_diyquan_home
        #redirect_to "http://taobao.iquan.net", status: 302
        #redirect_to "http://lanlan.iquan.net", status: 302
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
    if request.host == "www.zhequan.cc"
      render "zhequan"
      return
    end
    if request.host == "www.xiongmao123.com"
      render "xiongmao"
      return
    end
    if request.host == "zhaoquan.iquan.net"
      @title = "找券网 - 淘宝天猫优惠券大搜索 - 找券网"
      @description = "找券网 - 找券搜券淘券抢券拿券妈妈券宝宝券猪猪券内部券一网打尽，提供淘宝优惠券、天猫优惠券、内部优惠券、内部优惠卷、隐藏优惠券、隐藏券、隐藏优惠卷等实时查询服务，先搜索领券，再淘宝下单，专享爱券网折上折。每日更新大额优惠券、品牌优惠券、一折特价底价专场、9块9包邮白菜价好东西，加入搜藏，天天省钱 - 找券网。"
      @keywords = "找券,找券网,搜券,搜券网,zhaoquan,zhaoquanwang"
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
    @links = Link.where(status: 1).to_a
    render "diyquan/home", layout: "layouts/diyquan"
  end

  def m_diyquan_home
    url = "http://z.17gwx.com/web/index/index?client_id=zhekou_app_h5&client_secret=81f454ac98956541b195f2c7f9e53a06&page=0&pagesize=20"
    @coupons = JSON.parse(Net::HTTP.get(URI(url)))["data"]["coupon_list"]
    render "m_diyquan/home", layout: "layouts/m_diyquan"
  end
end
