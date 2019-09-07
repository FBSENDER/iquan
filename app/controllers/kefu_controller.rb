require 'kefu'
class KefuController < ApplicationController
  skip_before_action :verify_authenticity_token
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
    rescue
      render plain: 'success'
    end
  end
end
