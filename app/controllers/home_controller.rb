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
    @path = "/"
    diyquan_home
    #if is_device_mobile?
    #  m_diyquan_home
    #else
    #end
  end

  def diyquan_home
    @coupons = []
    @links = []
    render "diyquan/home", layout: "layouts/diyquan"
  end

  def m_diyquan_home
    @coupons = []
    render "m_diyquan/home", layout: "layouts/m_diyquan"
  end

  def yh
    redirect_to "http://www.uuhaodian.com/yh/#{params[:id]}/?channel=13", status: 302
  end
end
