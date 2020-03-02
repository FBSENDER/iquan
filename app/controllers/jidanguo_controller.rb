require 'net/http'
require 'jidanguo'

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
  $topics = [
    {id: 1, title: "这样的百香果还能吃吗？", src: "https://www.zhihu.com/question/375849673/answer/1048935696"},
    {id: 2, title: "请问有什么好一点的百香果店铺或者是链接（我想变白！！！）？", src: "https://www.zhihu.com/question/373036244/answer/1043800772"},
    {id: 3, title: "35块钱，买了40个左右的百香果，这个价格是正常价格还是？", src: "https://www.zhihu.com/question/375310309/answer/1044633427"},
    {id: 4, title: "百香果果肉挖出来和蜂蜜一起放冰箱冷藏后，拿出来常温能保存多久呀，想开学带去宿舍？", src: "https://www.zhihu.com/question/375120669/answer/1041860113"},
    {id: 5, title: "有什么能在家做又好喝的果茶？", src: "https://www.zhihu.com/question/263473452/answer/1040785911"}
  ]
  $shipin = [
    {id: 1, title: "爱吃百香果的注意了，快进来看看，现在知道还不晚！", pic: "https://timgmb01.bdimg.com/timg?haokan&quality=100&wh_rate=0&size=b576_324&ref=http%3A%2F%2Fwww.baidu.com&sec=1583137320&di=6a3eac4b96cbe8cf52f7bf95510ad143&src=http%3A%2F%2Ft12.baidu.com%2Fit%2Fu%3D1458504302%2C190574455%26fm%3D171%26s%3D36BC378FD2130FD29C8AEC6D0300B01B%26w%3D1200%26h%3D672%26img.JPEG", src: "https://haokan.baidu.com/v?vid=9882814460819950939", views: "14万"},
    {id: 2, title: "教你百香果最好吃的4种方法，步骤详细，吃法简单，比饮料更好喝", pic: "https://timgmb03.bdimg.com/timg?haokan&quality=100&wh_rate=0&size=b576_324&ref=http%3A%2F%2Fwww.baidu.com&sec=1583137791&di=3babe8ab33447be4cff4ba092db803da&src=http%3A%2F%2Ft12.baidu.com%2Fit%2Fu%3D1388824916%2C2471197329%26fm%3D171%26app%3D20%26f%3DJPEG%3Fw%3D1920%26h%3D1077%26s%3DDB88E30F4E037341469EAD640300A07B", src: "https://haokan.baidu.com/v?vid=14830288476978678175", views: "18万"},
    {id: 3, title: "百香果最好吃的3种方法，步骤简单详细，酸酸甜甜的比饮料更好喝", pic: "https://timgmb05.bdimg.com/timg?haokan&quality=100&wh_rate=0&size=b576_324&ref=http%3A%2F%2Fwww.baidu.com&sec=1583137791&di=48813108852fb652f7c64125f6d800b3&src=http%3A%2F%2Fvdposter.bdstatic.com%2F2e380d4625f83dece5e85e9a73f6f8a6.jpeg", src: "https://haokan.baidu.com/v?vid=4551443742474052287", views: "6.3万"},
    {id: 4, title: "百香果买皮皱的还是光面的？看完视频你就明白了，都看看", pic: "https://timgmb.bdimg.com/timg?haokan&quality=100&wh_rate=0&size=b576_324&ref=http%3A%2F%2Fwww.baidu.com&sec=1583137791&di=6c2691407c2d222ccc47251e904d54bc&src=http%3A%2F%2Fvdposter.bdstatic.com%2Fcd64c3aa3dc17fe8f548bef74ab11467.jpeg", src: "https://haokan.baidu.com/v?vid=6067897554007877855", views: "1.2万"},
    {id: 5, title: "看到这几种百香果最好不要买，知道的人不多，看完记得告诉家里人", pic: "https://timgmb04.bdimg.com/timg?haokan&quality=100&wh_rate=0&size=b576_324&ref=http%3A%2F%2Fwww.baidu.com&sec=1583137791&di=275274530fc856e800af62f4cdc1ec4c&src=http%3A%2F%2Ft10.baidu.com%2Fit%2Fu%3D494611896%2C1645350917%26fm%3D171%26app%3D20%26f%3DJPEG%3Fw%3D660%26h%3D370", src: "https://haokan.baidu.com/v?vid=8988475149101582647", views: "2.7万"},
    {id: 6, title: "在家自制蜂蜜百香果柠檬茶", pic: "https://timgmb01.bdimg.com/timg?haokan&quality=100&wh_rate=0&size=b576_324&ref=http%3A%2F%2Fwww.baidu.com&sec=1583138152&di=43ed7ce7e2c295aaa1d92e3e5bc481bb&src=http%3A%2F%2Ft12.baidu.com%2Fit%2Fu%3D1119914201%2C1666592055%26fm%3D171%26app%3D20%26f%3DJPEG%3Fw%3D1920%26h%3D1080%26s%3DED48C8181A61131747AC386703009060", src: "https://haokan.baidu.com/v?vid=2193121793598464942", views: "8412"},
    {id: 7, title: "百香果和蜂蜜放在一起太实用了，解决了女生的烦恼，能省不少钱", pic: "https://timgmb05.bdimg.com/timg?haokan&quality=100&wh_rate=0&size=b576_324&ref=http%3A%2F%2Fwww.baidu.com&sec=1583138255&di=77a5db1c672b0b5820000fbe5f83df2e&src=http%3A%2F%2Ft10.baidu.com%2Fit%2Fu%3D2242863870%2C3440472287%26fm%3D171%26app%3D20%26f%3DJPEG%3Fw%3D660%26h%3D370%26s%3D57A49E4504524A750EB0E87E03000073", src: "https://haokan.baidu.com/v?vid=8465554507730907746", views: "2.3万"},
    {id: 8, title: "百香果与蜂蜜结合一起大家都吃过，但我相信你们绝对没这么吃过", pic: "https://timgmb02.bdimg.com/timg?haokan&quality=100&wh_rate=0&size=b576_324&ref=http%3A%2F%2Fwww.baidu.com&sec=1583138255&di=4689d07c7dfa1c4405a69c2dc35cd536&src=http%3A%2F%2Ft10.baidu.com%2Fit%2Fu%3D516984996%2C3832054948%26fm%3D171%26s%3D8F84AC4C1FA7F176501B123D0300F05B%26w%3D1920%26h%3D1080%26img.JPEG", src: "https://haokan.baidu.com/v?vid=2069778153968970019", views: "1.5万"},
  ]

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
    @goods = Jidanguo.where(is_good: 1, status: 1).select(:id, :item_id, :pict_url, :title, :provcity, :volume, :shop_title).order("volume desc").limit(5)
    @products = Jidanguo.where(status: 1).select(:id, :item_id, :title, :shop_type, :volume, :pict_url, :price).order("volume desc").offset(5).limit(40)
    @tags = JidanguoTag.select(:id, :tag, :pinyin).to_a
    @shipin = $shipin
    @topics = $topics
    @links = JidanguoLink.where(status: 1).select(:url, :anchor).to_a
    @meta = get_articles_meta
    render :home, layout: "layouts/jidanguo"
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
    @ams = get_articles_meta
    @shipin = $shipin
    @topics = $topics
  end

  def tag
    @tag = JidanguoTag.where(pinyin: params[:pinyin]).take
    if @tag.nil? 
      not_found
      return
    end
    @tags = JidanguoTag.select(:id, :tag, :pinyin).to_a
    @products = []
    Jidanguo.connection.execute("select p.id, p.item_id, p.title, p.pict_url, p.shop_type, p.price, p.volume
from bxg_products p
join bxg_tag_products t on p.id = t.product_id
where t.tag_id = #{@tag.id} order by p.id desc limit 40").to_a.each do |row|
      @products << {
        id: row[0],
        item_id: row[1],
        title: row[2],
        pict_url: row[3],
        shop_type: row[4],
        price: row[5],
        volume: row[6]
      }
    end
    @ams = get_articles_meta
    @shipin = $shipin
    @topics = $topics
  end

  def taobao_buy
    if params[:id].nil? 
      not_found
      return
    end
    redirect_to "http://www.uuhaodian.com/yh/#{params[:id]}"
  end

  def product_list
    @products = Jidanguo.where(status: 1).select(:id, :item_id, :title, :shop_type, :volume, :pict_url, :price).order("id desc").offset(5).limit(100)
  end

end
