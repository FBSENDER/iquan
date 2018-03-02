function clear_content(){
  $("#search_input").val("");
  $("#query_info").text("");
  $("#btn_coupon").hide();
  $("#btn_product").hide();
  $("#btn_app").hide();
}

function get_title(data){
  var m = /【.*\((.*)\)】/.exec(data);
  if(m != null){
    return m[1]
  }
  m = /【(.*)】/.exec(data);
  if(m != null){
    return m[1]
  }
  return data;
}

function fix_coupon_position(){
  var width = $(".wrapper").width();
  $(".go-coupon").attr("style", "left:" + (width/2 * (-1) + 200) + "px");
  $(".new-product").attr("style", "left:" + (width/2 - 230) + "px");
  $(".amount").attr("style", "left:" + (width/2 - 200) + "px");
  $(".time").attr("style", "left:" + (width/2 - 200) + "px");
}

function quick_query_title(title, is_taokouling){
  var $query_info = $("#query_info");
  $.ajax({
    url: "/quick_query_title/",
    type: 'GET',
    dataType: 'json',
    data: {
      keyword: title,
      is_taokouling: is_taokouling
    },
    success: function(data){
      if(data.status == 1){
        $query_info.text("查询成功：\n" + title + "\n" + data.price + "元优惠券");
        $("#coupon_price").text(data.price);
        $("#coupon_end_time").text("至 " + data.end_time);
        $("#coupon_link").attr("href", data.url);
        $("#btn_coupon").show();
      }
      else if(data.status == 2){
        $query_info.text("查询成功：\n" + title);
        window.location.href = data.url;
      }
      else if(data.status == 3){
        $query_info.text("查询成功：\n" + title);
        $("#product_link").attr("href", data.url);
        $("#product_price").text("折扣价 " + data.price + " 元");
        $("#btn_product").show();
      }
      else if(data.status == 4){
        $query_info.text("查询成功：\n" + title);
        window.location.href = data.url;
      }
      else if(data.status == 5){
        $query_info.text("查询成功：\n" + title);
        window.location.href = data.url;
      }
      else if(data.status == -1){
        $query_info.text("查询失败：\n" + title + "\n请尝试直接输入宝贝标题进行搜索~");
        $("#btn_app").show();
      }
    }
  });
}

function begin_quick_search(){
  var $query_info = $("#query_info");
  $query_info.text("");
  var $search_input = $("#search_input");
  var data = $search_input.val().trim();
  if(data == ""){
    $query_info.text("请输入宝贝信息后点击查询~");
    return;
  }
  var title = get_title(data);
  var is_taokouling = title != data ? 1: 0;

  $query_info.text("正在查询：\n" + title + "\n请稍候...");
  quick_query_title(title, is_taokouling);
}

$(document).ready(function(){
  fix_coupon_position();
  $("#search_input").on("keypress", function(e){
    if(e.keyCode == 13){
      begin_quick_search();
    }
  });
});
