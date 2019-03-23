require 'net/http'

class JidanguoController < ApplicationController
  $home_item_list = {
    updated_at: 0,
    data: []
  }
  $keywords = %w(百香果大果 黄金百香果 百香果苗 百香果酱 百香果汁 百香果干 百香果茶 百香果原浆)

  def update_home_item_list
    url = "http://api.uuhaodian.com/ddk/search?keyword=百香果"
    result = Net::HTTP.get(URI(URI.encode(url)))
    json = JSON.parse(result)
    if json["status"]["code"] == 1001
      $home_item_list = {
        updated_at: Time.now.to_i,
        data: json["result"]
      }
      return true
    end
    return false
  end

  def get_home_item_list
    if Time.now.to_i - $home_item_list[:updated_at] > 1000
      update_home_item_list
    end
    $home_item_list[:data]
  end

  def home
    @items = get_home_item_list
    @keywords = $keywords
    render :home, layout: "layouts/jidanguo"
  end

  def ddh
    url = "http://api.uuhaodian.com/ddk/product?id=#{params[:id]}"
    result = Net::HTTP.get(URI(URI.encode(url)))
    json = JSON.parse(result)
    if json["status"]["code"] != 1001
      not_found
      return
    end
    @detail = json["result"]
    @items = get_home_item_list
    @keywords = $keywords
  end

  def query
    @items = []
    @keyword = params[:keyword]
    @keywords = $keywords
    unless $keywords.include?(@keyword)
      not_found
      return
    end
    url = "http://api.uuhaodian.com/ddk/search?keyword=#{@keyword}"
    result = Net::HTTP.get(URI(URI.encode(url)))
    json = JSON.parse(result)
    if json["status"]["code"] == 1001
      @items = json["result"]
    end
  end

end
