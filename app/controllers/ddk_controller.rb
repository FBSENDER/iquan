class DdkController < ApplicationController
  def not_found
    render "not_found", status: 404
  end
  def youhui
    @keyword = params[:keyword]
    @cates = get_cate_data
    @top_keywords = get_hot_keywords_data.sample(8)
    @path = "https://api.uuhaodian.com/ddk/search"
  end

  def product_detail
    url = "http://api.uuhaodian.com/ddk/product?id=#{params[:id]}"
    result = Net::HTTP.get(URI(URI.encode(url)))
    json = JSON.parse(result)
    if json["status"] == 0 || json["status"]["code"] != 1001
      not_found
      return
    end
    @detail = json["result"]
    @promotion_url = "http://m.iquan.net"
    purl = "http://api.uuhaodian.com/ddk/promotion_url?id=#{params[:id]}"
    presult = Net::HTTP.get(URI(purl))
    pjson = JSON.parse(presult)
    if pjson["status"] == 1
      @promtion_url = pjson["result"]["we_app_web_view_short_url"]
    end
    @top_keywords = get_hot_keywords_data.sample(8)
    @path = "https://api.uuhaodian.com/ddk/search"
  end

  def category
    @cid = params[:cid]
    @cid_1 = params[:cid_1]
    @cates = get_cate_data
    @lanlan_category = @cates.select{|c| c["cid"] == @cid || c["cid"] == params[:cid_1]}.first
    if @lanlan_category.nil?
      not_found
      return
    end
    @category_name = params[:category_name] || @lanlan_category["name"]
    @top_keywords = get_hot_keywords_data.sample(8)
    @path = "https://api.uuhaodian.com/ddk/search"
  end

  def rec
    @type = params[:type].to_i - 1
    @title = @type == 0 ? '1.9包邮' : @type == 1 ? '今日爆款' : '品牌清仓'
    @keywords = @title
    @top_keywords = get_hot_keywords_data.sample(8)
    @path = "https://api.uuhaodian.com/ddk/rec_list"
  end
end
