class HomeController < ApplicationController
  def index
    if(params[:mod] || params[:ac] || params[:r])
      redirect_to "/", status: 301
      return
    end
    if request.host == $pc_host && is_device_mobile?
      redirect_to "http://#{$mobile_host}", status: 302
      return
    end
    if is_device_mobile?
      if is_robot?
        render "lanlan_home", layout: nil
      else
        redirect_to "http://m.uuhaodian.com/index.php?r=index/wap&source=m_shikuai"
      end
    else
      diyquan_home
    end
  end

  def diyquan_home
    if is_robot?
      #@coupons = get_static_coupons('static_new_coupons')
      @coupons = get_home_coupons
    else
      @coupons = []
    end
    @meta = get_articles_meta
    @links = Link.where(status: 1).to_a
    render "diyquan/home", layout: "layouts/diyquan"
  end

  def m_diyquan_home
    @coupons = get_static_coupons('static_new_coupons')
    render "m_diyquan/home", layout: "layouts/m_diyquan"
  end

  def get_home_coupons
    url = "http://www.shikuaigou.com/getLanlanHomeCouponList"
    result = Net::HTTP.get(URI(url))
    data = JSON.parse(result)
    if data["status"] && data["status"]["code"] && data["status"]["code"] == 1001
      return data["result"]
    else
      return []
    end
  end
end
