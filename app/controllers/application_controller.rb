require 'common_config'
require 'net/http'
require 'zkapi/zk_api'
require 'zkapi/lanlan_api'
require 'iquan'
require 'seo_domain'
require 'timeout'
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

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
  $article_meta = {
    meta: {},
    updated_at: 0
  }
  def update_articles_meta
    meta_yaml = Rails.root.join("vendor/articles").join("meta.yaml")
    if File.exists?(meta_yaml)
      meta = YAML.load(File.read(meta_yaml))
      $article_meta = {
        updated_at: Time.now.to_i,
        meta: meta
      }
    end
  end
  def get_articles_meta
    if Time.now.to_i - $article_meta[:updated_at] > 1000
      update_articles_meta
    end
    $article_meta[:meta]
  end
end
