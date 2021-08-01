class AmpController < ApplicationController
  include DiyquanHelper
  def qq
    @keyword = params[:keyword].strip.force_encoding('utf-8')
   # unless is_robot?
   #   if is_device_mobile?
   #     redirect_to "http://tt.uuhaodian.com/dz/#{URI.encode_www_form_component(@keyword)}/?from=amp_shikuai", status: 302
   #   else
   #     redirect_to "http://www.uuhaodian.com/query/#{URI.encode_www_form_component(@keyword)}/?from=amp_shikuai", status: 302
   #   end
   #   return
   # end
    @title = "#{@keyword}_#{@keyword}多少钱/打折/包邮_十块购"
    @description = "十块购为您提供#{@keyword}打折优惠价格信息，包括#{@keyword}价格、#{@keyword}多少钱、#{@keyword}打折信息、#{@keyword}包邮特卖，便宜超值的今日特价，就在十块购！"
    @page_keywords = "#{@keyword},#{@keyword}多少钱,#{@keyword}价格,#{@keyword}特价,#{@keyword}包邮,#{@keyword}打折"
    @path = "#{request.path}/"
    @h1 = @keyword
    #@items = get_dg_items(@keyword)
    @items = []
    data  = get_tbk_search_json(@keyword, 1)
    if data["tbk_dg_material_optional_response"] && data["tbk_dg_material_optional_response"]["result_list"] && data["tbk_dg_material_optional_response"]["result_list"]["map_data"].size > 0
      @items = data["tbk_dg_material_optional_response"]["result_list"]["map_data"]
    end
    infos = get_dg_keyword_infos(@keyword)
    @keywords = infos && infos["r_keywords"] ? infos["r_keywords"] : []
    @cats = infos && infos["r_cats"] ? infos["r_cats"] : []
    @selectors = infos && infos["selector"] ? infos["selector"] : []
    @is_mobile = is_device_mobile?
    render "amp/qq", layout: "layouts/amp_diyquan"
  end

  def get_dg_items(keyword)
    url = "http://api.uuhaodian.com/uu/dg_goods_list?keyword=#{keyword}&is_simple=1"
    result = Net::HTTP.get(URI(URI.encode(url)))
    json = JSON.parse(result)
    if json["status"] == 1
      return json["results"]
    else
      return []
    end
  end

  def get_dg_keyword_infos(keyword)
    url = "http://api.uuhaodian.com/uu/keyword_infos?keyword=#{keyword}"
    result = Net::HTTP.get(URI(URI.encode(url)))
    json = JSON.parse(result)
    if json["status"] == 1
      return json["result"]
    else
      return nil
    end
  end

  def get_tbk_search_json(keyword, page_no)
    tbk = Tbkapi::Taobaoke.new
    JSON.parse(tbk.taobao_tbk_dg_material_optional(keyword, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, '6707', $taobao_app_id_material, $taobao_app_secret_material, $taobao_adzone_id_material, page_no, 20 ))
  end
end
