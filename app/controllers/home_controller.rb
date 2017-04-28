require 'seo_domain'
class HomeController < ApplicationController
  @@compete_brands = nil
  def index
    if !is_robot?
      redirect_to "http://taobao.iquan.net", status: 302
      return
    end
    if @@compete_brands.nil? || Time.now.to_i % 600 == 0
      @@compete_brands = CompeteBrand.select(:title, :keywords, :description, :host).to_a
    end
    if request.host.include?(".youhui.iquan.net")
      brand = CompeteBrand.where(host: request.host).take
      not_found if brand.nil?
      @title = brand.title
      @keywords = brand.keywords
      @description = brand.description
    end
    @compete_brands = @@compete_brands
    @path = "/"
  end
end
