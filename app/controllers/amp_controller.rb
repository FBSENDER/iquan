class AmpController < ApplicationController
  def zhekou
    @keyword = params[:keyword].force_encoding('utf-8')
    @title= "【#{@keyword}】_#{@keyword}折扣_#{@keyword}优惠券_#{$website_name}"
    @description = "淘宝天猫隐藏#{@keyword}优惠券,#{@keyword}折扣,#{@keyword}包邮,20元50元100元优惠券,先领券,再下单,专享淘宝折上折优惠.领取#{@keyword}优惠券,查看#{@keyword}打折特价信息 - #{$website_name}"
    @page_keywords = "#{@keyword},#{@keyword}优惠,#{@keyword}优惠券,#{@keyword}折扣,特价#{@keyword}"
    @big_keywords = $big_keywords
    @h1 = @keyword
    @seo_k = @h1
    @path = "/zhekou/#{URI.encode(@keyword)}/"
    @links = []
    @keyword = params[:keyword].strip
    @items = get_dg_items(@keyword)
    infos = get_dg_keyword_infos(@keyword)
    @keywords = infos && infos["r_keywords"] ? infos["r_keywords"] : []
    @cats = infos && infos["r_cats"] ? infos["r_cats"] : []
    @selectors = infos && infos["selector"] ? infos["selector"] : []
    @shops = []
    render "amp/zhekou", layout: "layouts/amp_diyquan"
  end
end
