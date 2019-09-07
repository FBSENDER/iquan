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
      else
        receive_message_other(m.user_id)
      end
    rescue
      render plain: 'success'
    end
  end

  def receive_message_1(open_id)
    ids = SwanUser.where(open_id: open_id).pluck(:swan_id)
    if ids.size.zero?
      msg = "更多优惠优优好店官网：uuu.uuhaodian.com"
      send_message(open_id, msg)
      return
    end
    click = KefuClick.where(swan_id: ids).order("id desc").limit(1)
    if click.nil?
      msg = "更多优惠优优好店官网：uuu.uuhaodian.com"
      send_message(open_id, msg)
      return
    end
    msg = "购买链接：www.gouwuzhinan.cn/uu/buy?id=#{click.item_id}&channel=18"
    send_message(open_id, msg)
  end

  def receive_message_other(open_id)
    msg = "更多优惠优优好店官网：uuu.uuhaodian.com"
    send_message(open_id, msg)
  end

  def send_message(open_id, msg)
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
    render json: {status: 1}
  end
end
