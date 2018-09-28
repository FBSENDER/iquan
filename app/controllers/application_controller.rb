require 'common_config'
require 'net/http'
require 'zkapi/zk_api'
require 'zkapi/lanlan_api'
require 'iquan'
require 'seo_domain'
require 'timeout'
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  $coupon_9kuai9_data = {}
  $cate_data = {}
  $hot_keywords_data = {}

  def is_robot?
    user_agent = request.headers["HTTP_USER_AGENT"]
    user_agent.present? && user_agent =~ /(bot|spider|slurp)/i || user_agent == "Mozilla/5.0"
  end

  def is_device_mobile?
    user_agent = request.headers["HTTP_USER_AGENT"]
    user_agent.present? && user_agent =~ /\b(Android|iPhone|Windows Phone|Opera Mobi|Kindle|BackBerry|PlayBook|UCWEB|Mobile)\b/i
  end
  def redirect_pc_to_mobile
    if request.host == $pc_host && is_device_mobile?
      redirect_to "http://#{$mobile_host}#{request.path}/", status: 302
      return true
    end
    return false
  end
  def not_found
    raise ActionController::RoutingError.new('NOT FOUND')
  end
  def is_keyword_url?(keyword)
    keyword =~ /(http|taobao|tmall)/i  
  end

  def get_tb_id(url)
    m = url.match(/id=(\d+)/i)
    return m[1] if m
    nil
  end

  def get_suggest_keywords_new(keyword)
    begin
      sk = SuggestKeyword.where(keyword: keyword).take
      return [] if sk.nil?
      sk.sks.split(',')
    rescue
      return []
    end
  end

  def get_suggest_keywords_new_new(keyword)
    begin
      sk = SuggestKeywordNew.where(keyword: keyword).take
      return [] if sk.nil?
      sk.sks.split(',').sample(20)
    rescue
      return []
    end
  end

  def is_taobao_title?(keyword)
    keyword.size > 18
  end

  def get_referer_search_keyword
    return nil if request.referer.nil?
    uri = URI(request.referer)
    return nil if uri.query.nil?
    ps = CGI.parse(uri.query)
    ks = ps["keyword"] || ps["word"]
    if ks && ks.size > 0
      return ks.first
    else
      return nil
    end
  end

  def get_title_from_search_keyword(keyword)
    return nil if keyword.nil? || keyword.empty?
    m = keyword.match(/【.*\((.*)\).*】/)
    return m[1] if m
    m = keyword.match(/【.*（(.*)）.*】/)
    return m[1] if m 
    m = keyword.match(/【(.*)】/)
    return m[1] if m
    m = keyword.match(/（(.*)）/)
    return m[1] if m
    m = keyword.match(/\((.*)\)/)
    return m[1] if m
    nil
  end

  def get_coupon_9kuai9_data
    if $coupon_9kuai9_data["update_at"].nil? || $coupon_9kuai9_data["items"].nil? || $coupon_9kuai9_data["items"].size.zero? || Time.now.to_i - $coupon_9kuai9_data["update_at"] > 3600
      url = "http://api.uuhaodian.com/uu/jiukuaijiu_list"
      result = Net::HTTP.get(URI(url))
      json = JSON.parse(result)
      if json["status"] && json["status"]["code"] == 1001
        $coupon_9kuai9_data["items"] = json["result"]
        $coupon_9kuai9_data["update_at"] = Time.now.to_i
        return $coupon_9kuai9_data["items"]
      else
        return []
      end
    end
    return $coupon_9kuai9_data["items"]
  end

  def get_tbk_search_json(keyword, page_no)
    tbk = Tbkapi::Taobaoke.new
    JSON.parse(tbk.taobao_tbk_item_get(keyword, $taobao_app_id, $taobao_app_secret, page_no + 1,50))
  end

  def get_cate_data
    if $cate_data.nil? || $cate_data["update_at"].nil? || $cate_data["cate"].nil? || $cate_data["cate"].size.zero? || Time.now.to_i - $cate_data["update_at"] > 3600
      url = "http://api.uuhaodian.com/uu/category_list"
      result = Net::HTTP.get(URI(url))
      json = JSON.parse(result)
      if json["status"] && json["status"]["code"] == 1001
        $cate_data["cate"] = json["result"].sort{|a, b| a["cid"].to_i <=> b["cid"].to_i}
        $cate_data["cate"].each do |c|
          c["img_url"] = c["list"][0]["image"]
        end
        $cate_data["update_at"] = Time.now.to_i
        return $cate_data["cate"]
      else
        return []
      end
    end
    return $cate_data["cate"]
  end

  def get_hot_keywords_data
    if $hot_keywords_data["update_at"].nil? || $hot_keywords_data["keywords"].nil? || $hot_keywords_data["keywords"].size.zero? || Time.now.to_i - $hot_keywords_data["update_at"] > 3600
      url = "http://api.uuhaodian.com/uu/hot_keywords"
      result = Net::HTTP.get(URI(url))
      json = JSON.parse(result)
      if json["status"] && json["status"]["code"] == 1001
        $hot_keywords_data["keywords"] = json["result"]
        $hot_keywords_data["update_at"] = Time.now.to_i
        return $hot_keywords_data["keywords"]
      else
        return []
      end
    end
    return $hot_keywords_data["keywords"]
  end

end
