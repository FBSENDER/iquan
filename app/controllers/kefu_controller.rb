require 'kefu'
class KefuController < ApplicationController
  skip_before_action :verify_authenticity_token
  $swan_token = nil
  def check_post_message
    arr = ['uuapi', params[:timestamp], params[:nonce]].sort
    tmp_str = arr.join('')
    key = Digest::SHA1.hexdigest(tmp_str)
    puts params[:signature]
    if key == params[:signature]
      render plain: params[:echostr] || params[:echoStr]
    else
      render plain: "fail"
    end
  end

  def receive_message
    begin
      m = KefuMessage.new
      m.user_id = params[:FromUserName]
      m.mtime = params[:CreateTime].to_i
      m.mtype = params[:MsgType] == "text" ? 1 : 2
      m.content = params[:Content] || params[:PicUrl]
      m.mid = params[:MsgId].to_i
      m.save
      render plain: 'success'
      if m.mtype == 1 && m.content == '1'
        receive_message_1(m.user_id)
        receive_message_other(m.user_id)
      elsif m.mtype == 1 && m.content == '2'
        receive_message_2(m.user_id)
      elsif m.mtype == 1 && m.content == '3'
        receive_message_3(m.user_id)
      elsif m.mtype == 1 && m.content == '4'
        receive_message_4(m.user_id)
      elsif m.mtype == 1 && m.content == '5'
        receive_message_5(m.user_id)
      else
        receive_message_other(m.user_id)
      end
    rescue
    end
  end

  def receive_message_1(open_id)
    ids = SwanUser.where(open_id: open_id).pluck(:swan_id)
    if ids.size.zero?
      msg = "未能获取购买链接"
      send_message(open_id, msg)
      return
    end
    click = KefuClick.where(swan_id: ids).order("id desc").take
    if click.nil?
      msg = "未能获取购买链接"
      send_message(open_id, msg)
      return
    end
    if click.kouling.nil?
      if click.taobao_url.nil?
        msg = "购买链接：www.gouwuzhinan.cn/uu/buy?id=#{click.item_id}&channel=18\n如果不展示商品，就再点一次链接~"
        send_message(open_id, msg)
      else
        msg = "购买链接：www.gouwuzhinan.cn/uu/g/#{click.id}\n如果不展示商品，就再点一次链接~"
        send_message(open_id, msg)
      end
    else
      if click.taobao_url.nil?
        msg = "购买链接：www.gouwuzhinan.cn/uu/buy?id=#{click.item_id}&channel=18\n长按复制#{click.kouling} 打开「手机淘宝」可以直接购买\n如果不展示商品，就再点一次链接~"
        send_message(open_id, msg)
      else
        msg = "购买链接：www.gouwuzhinan.cn/uu/g/#{click.id}\n长按复制#{click.kouling} 打开「手机淘宝」可以直接购买\n如果不展示商品，就再点一次链接~"
        send_message(open_id, msg)
      end
    end
  end

  def receive_message_2(open_id)
    msg = "9.9划算节满200减20：s.click.taobao.com/sTPcV1w \n淘宝新人188元红包：s.click.taobao.com/86NcV1w \n天猫超市中秋大促：s.click.taobao.com/j41cV1w \n 每日10点,精选好货：s.click.taobao.com/J2vbV1w"
    send_message(open_id, msg)
  end

  def receive_message_3(open_id)
    msg = "关注微信公众号「优优好店」查看合作详情"
    send_message(open_id, msg)
  end

  def receive_message_4(open_id)
    msg = "官网与APP下载：uuu.uuhaodian.com"
    send_message(open_id, msg)
  end

  def receive_message_5(open_id)
    msg = "好店推荐：shop381966684.m.taobao.com"
    send_message(open_id, msg)
  end

  def receive_message_other(open_id)
    msg = "回复 1  获取购买链接\n回复 2  查看最新优惠活动\n回复 3  商家合作\n回复 4  官方网站与APP下载\n回复 5  好店推荐\n如何购买？m.uuhaodian.com/ggg/guide1.html\n更多优惠 uuu.uuhaodian.com"
    send_message(open_id, msg)
  end

  def send_message(open_id, msg, rty = 2)
    rr = rty
    if rr <= 0 
      return
    end
    rr = rr - 1
    if $swan_token.nil? || Time.now.to_i - $swan_token[:update_time] > 3600
      t = KefuToken.take.token
      $swan_token = {:token => t, :update_time => Time.now.to_i}
    end
    url = 'https://openapi.baidu.com/rest/2.0/smartapp/message/custom/send'
    qq = {
      access_token: $swan_token[:token],
      user_type: 2,
      open_id: open_id,
      msg_type: 'text',
      content: msg,
      pic_url: ''
    }
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
    request.body = URI.encode_www_form(qq)
    response = http.request(request)
    logger.info(response.body)
    unless response.body.include?('success')
      sleep(1)
      send_message(open_id, msg, rr)
    end
  end
end
