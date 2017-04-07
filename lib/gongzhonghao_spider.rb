$cookie = ''

def search_author(keyword, page = 1)
  url = "http://weixin.sogou.com/weixin?query=#{keyword}&type=1&page=#{page}&ie=utf8"
  body = Nokogiri::HTML HTTParty.get(URI.encode(url), :headers => {"Cookie" => $cookie}) 
  result = []
  body.css("div._item").each do |div|
    link = div.attr("href")
    name = div.css("h3").first.text
    id = div.css("h4").first.css("label").first.text
    result << {id: id, name: name, link: link}
  end
  result
end

def article_list(url)
  response = HTTParty.get(url, :headers => {"Content-Type" => "text/html; charset=UTF-8","Cookie" => $cookie})
  body = ''
  hash = {}
  response.each_line do |line|
    data = line.match(/var msgList = (.+);/)
    if data
      body = data[1]
    end
  end
  unless body.empty?
    hash = JSON.parse(HTMLEntities.new.decode(body))
  end
  urls = []
  return unless hash['list']
  hash["list"].each do |item|
    urls << [HTMLEntities.new.decode(item["app_msg_ext_info"]["content_url"]).sub('\\','http://mp.weixin.qq.com'), item["app_msg_ext_info"]["cover"].gsub("\\",'')]
    item["app_msg_ext_info"]["multi_app_msg_item_list"].each do |it|
      urls << [HTMLEntities.new.decode(it["content_url"]).sub('\\','http://mp.weixin.qq.com'), it["cover"].gsub("\\",'')]
    end
  end
  urls
end

def article_detail(url, cover, author_id)
  body = Nokogiri::HTML HTTParty.get(url, :headers => {"Cookie" => $cookie})
  title = body.css("h2#activity-name").text.strip
  return false if Article.exists?(source_title: title)
  article_content = []
  article_content << {type: 11, h1_content: title}
  body.css("div#js_content").first.css("p").each do |p|
    img = p.css("img").first
    if img
      src = img.attr("data-src")
      desc = p.text.strip
      width = img.attr("data-w") || 500
      article_content << {type: 1, image_url: src, image_desc: desc, image_width: width, image_height: width}
    else
      text = p.text.strip
      article_content << {type: 2, text_type:2, text_content: text} unless text.empty?
    end
  end
  article = Article.new
  article.title = title
  article.source_title = title
  article.keywords = ''
  article.description = article_content.select{|item| item[:type] == 2}[0..10].map{|item| item[:text_content]}.join[0..100] + "..."
  article.article_content = article_content.to_json
  article.status = 0
  article.img_url = cover || ''
  article.author_id = author_id
  article.save
  true 
end

ids = %w(gzh_id_list)
ids.reverse.each do |id|
  begin
    result = search_author(id)
    r = article_list(result[0][:link])
    r.each do |u|
      break unless article_detail("http://mp.weixin.qq.com#{u[0]}",u[1],id)
    end
  rescue Exception => ex
    puts ex
    next
  end
end
