require 'net/http'

class JidanguoController < ApplicationController
  $home_item_list = {
    updated_at: 0,
    data: []
  }
  $article_meta = {
    meta: {},
    updated_at: 0
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

  def update_articles_meta
    meta_yaml = Rails.root.join("vendor/articles").join("meta.yaml")
    if File.exists?(meta_yaml)
      meta = YAML.load(File.read(meta_yaml))
      $article_meta = {
        updated_at: Time.now.to_i,
        meta: meta
      }
    else
      $article_meta = {
        updated_at: 0,
        meta: {
          articles: []
        }
      }
    end
  end

  def get_articles_meta
    if Time.now.to_i - $article_meta[:updated_at] > 1000
      update_articles_meta
    end
    $article_meta[:meta]
  end

  def home
  #  @items = get_home_item_list
  #  @keywords = $keywords
  #  @meta = get_articles_meta
    render :home, layout: "layouts/jidanguo"
  end

  def ddh
    url = "http://api.uuhaodian.com/ddk/product?id=#{params[:id]}"
    result = Net::HTTP.get(URI(URI.encode(url)))
    json = JSON.parse(result)
    if json["status"] == 0 || json["status"]["code"] != 1001
      not_found
      return
    end
    @detail = json["result"]
    @items = get_home_item_list
    @keywords = $keywords
    @ams = get_articles_meta
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
    @ams = get_articles_meta
  end

  def article
    meta = get_articles_meta
    if meta.size.zero?
      not_found
      return
    end
    sac = meta[:articles].select{|m| m[:id] == params[:id]}.first
    if sac.nil?
      not_found
      return
    end
    file = Rails.root.join("vendor/articles").join(sac[:file])
    html = Rails.root.join("vendor/articles").join("#{sac[:id]}.html")
    if !File.exists?(file) || !File.exists?(html)
      not_found
      return
    end
    f = File.read(file)
    content = f.split("######")
    @meta = YAML.load(content[0])[:article]
    @html = File.read(html)
    @items = get_home_item_list
    @keywords = $keywords
    @ams = get_articles_meta
  end

end
