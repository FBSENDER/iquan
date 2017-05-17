require 'seo_domain'
class HomeController < ApplicationController
  @@compete_brands = nil
  def index
    if request.host == "www.ichaopai.cc"
      render "ichaopai"
      return
    end
    if !is_robot? && request.host != "www.zhequan.cc"
      redirect_to "http://taobao.iquan.net", status: 302
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
end
