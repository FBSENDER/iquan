var Util = Util || {};

Util.pageSize = function() {
  var a = document.documentElement;
  var b = ["clientWidth", "clientHeight", "scrollWidth", "scrollHeight"];
  var c = {};
  for (var d in b) c[b[d]] = a[b[d]];
  c.scrollLeft = document.body.scrollLeft || document.documentElement.scrollLeft;
  c.scrollTop = document.body.scrollTop || document.documentElement.scrollTop;
  return c;
};

Util.lazyLoad = function(cn){
  var lazyImg = $('.'+cn);

  lazyImg.each(function(){
    var _this = $(this);
    var url = _this.attr('data-original');

    $('<img />').one('load',function(){
      if(_this.is('img')){
        _this.attr('src',url);
      }else{
        _this.css('background-image','url('+url+')');
      }
      setTimeout(function(){
        _this.css('opacity','1');
      },15);
    }).one('error',function(){
      _this.css('opacity','1');
    }).attr('src',url);
  });
}

Util.createLanlanCouponList = function(cl,obj,channel,gaPage){
  gaPage = gaPage || '未知';
  var htmlstr = '<div>';
  for(var i=0,len=cl.length;i<len;i++){
    var z = cl[i];
    var re = /activityId=(\w*)/;
    var buy_url = 'https://www.uuhaodian.com/yh/' + z.itemId + '/?from=iquan';
    buy_url += "&coupon_money=" + parseInt(z.couponMoney)
    buy_url += "#coupon"
    var platform = '',platformPic = '';
    if(z.shopType == 'tmall')
      platform = 2;
    else
      platform = 1;
    htmlstr += '<div class="zk-item">';
    htmlstr += '<a href="'+ buy_url +'" target="_blank">';
    htmlstr += '<div class="img-area">';
    htmlstr += '<div class="bottom-info">';
    htmlstr += '<p data-endtime="'+ z.couponEndTime +'" class="time-count"></p>';
    htmlstr += '</div>';
    htmlstr += '<img data-ga-event="商品_图片:点击:'+ gaPage +'" class="lazy new" data-original="'+ z.coverImage.replace('http:', '') +'" alt="'+z.title +'">';
    htmlstr += '</div>';
    htmlstr += '<p class="title-area">';
    htmlstr +=  z.shortTitle +'</p>';
    htmlstr += '<div class="tags-area">'
    if(platform == 2){
      htmlstr += '<span class="tag">天猫</span>';
    }
    else{
      htmlstr += '<span class="tag taobao">淘宝</span>';
    }
    if(z.shopName.indexOf('旗舰店') > 0){
      htmlstr += '<span class="tag">旗舰店</span>';
    }
    if(z.activityType == 2){
      htmlstr += '<span class="tag">淘抢购</span>';
    }
    else if(z.activityType == 3){
      htmlstr += '<span class="tag">聚划算</span>';
    }
    if(z.couponMoney > 0){
      htmlstr += '<span class="tag c">' + parseInt(z.couponMoney) + '元券</span>';
    }
    htmlstr += '</div>'
    htmlstr += '<div class="price-area">';
    htmlstr += '券后价 ￥ <span class="price">' + (z.nowPrice > 0 ? z.nowPrice : z.price)  + '</span>';
    htmlstr += '</div>';
    htmlstr += '<div class="raw-price-area">原价：&yen;'+ z.price;
    if(z.monthSales > 0){
      var vv = z.monthSales > 10000 ? ((z.monthSales / 10000).toFixed(1) + '万') : z.monthSales
      htmlstr += '<p class="sold">' + vv +'人已付款</p>'
    }
    htmlstr += '</div>';
    htmlstr += '</div>';
    htmlstr += '</a>';
    htmlstr += '</div>';
  }
  htmlstr += '</div>';
  htmlstr = $(htmlstr);
  htmlstr.find('[data-ga-event]').on('click',function(){
    var _this = $(this);
    var gaEvent = _this.attr('data-ga-event');
    var gaParmas = gaEvent.split(':');
    if(typeof ga != 'undefined' && gaParmas.length >= 3){
      ga('send','event',gaParmas[0],gaParmas[1],gaParmas[2]);
    }
  });
  obj.append(htmlstr);
  Util.lazyLoad('lazy.new');
  $('.lazy.new').removeClass('new');
}

Util.createDgList = function(cl,obj,channel,gaPage){
  gaPage = gaPage || '未知';
  var htmlstr = '<div>';
  for(var i=0,len=cl.length;i<len;i++){
    var z = cl[i];
    var coupon_money = z.coupon_amount ? parseInt(z.coupon_amount) : 0;
    var now_price = (parseFloat(z.zk_final_price) - coupon_money).toFixed(2);
    var o_price = coupon_money > 0 ? parseFloat(z.zk_final_price).toFixed(2) : parseFloat(z.reserve_price).toFixed(2);
    var zhe = (now_price * 10.0 / o_price).toFixed(1);
    var platform = '',platformPic = '';
    htmlstr += '<div class="zk-item">';
    if(coupon_money > 0){
      htmlstr += '<a href="https://www.uuhaodian.com/yh/'+ z.item_id +'/?coupon_money=' + coupon_money + '#coupon" target="_blank">';
    }
    else{
      htmlstr += '<a href="https://www.uuhaodian.com/yh/'+ z.item_id +'/#coupon" target="_blank">';
    }
    htmlstr += '<div class="img-area">';
    htmlstr += '<img class="lazy new" data-original="'+ z.pict_url +'" alt="'+z.
      title +'">';
    htmlstr += '</div>';
    htmlstr += '<p class="title-area">';
    if(z.short_title != ''){
      htmlstr +=  z.short_title +'</p>';
    }
    else{
      htmlstr +=  z.title +'</p>';
    }
    htmlstr += '<div class="tags-area">'
    if(z.user_type == 1){
      htmlstr += '<span class="tag">天猫</span>';
    }
    else{
      htmlstr += '<span class="tag taobao">淘宝</span>';
    }
    if(z.shop_title.indexOf('旗舰店') > 0){
      htmlstr += '<span class="tag">旗舰店</span>';
    }
    if(coupon_money > 0){
      htmlstr += '<span class="tag c">' + coupon_money + '元券</span>';
    }
    htmlstr += '</div>'
    htmlstr += '<div class="price-area">';
    if(coupon_money > 0){
      htmlstr += '券后价 ￥ <span class="price">' + now_price + '</span>';
    }
    else{
      htmlstr += '折扣价 ￥ <span class="price">' + now_price + '</span>';
    }
    htmlstr += '</div>';
    htmlstr += '<div class="raw-price-area">原价：&yen;'+ o_price;
    if(z.volume > 0){
      var vv = z.volume > 10000 ? ((z.volume / 10000).toFixed(1) + '万') : z.volume
      htmlstr += '<p class="sold">' + vv +'人已付款</p>'
    }
    htmlstr += '</div>';
    htmlstr += '</div>';
    htmlstr += '</a>';
    htmlstr += '</div>';
  }
  htmlstr += '</div>';
  htmlstr = $(htmlstr);
  obj.append(htmlstr);
  Util.lazyLoad('lazy.new');
  $('.lazy.new').removeClass('new');
}

Util.createJdList = function(cl,obj,channel,gaPage){
  gaPage = gaPage || '未知';
  var htmlstr = '<div>';
  for(var i=0,len=cl.length;i<len;i++){
    var z = cl[i];
    var coupon_money = z.coupon_amount ? parseInt(z.coupon_amount) : 0;
    var buy_url = "https://www.uuhaodian.com/jd/" + z.item_id + '/#coupon';
    if(coupon_money == 0 && z.price_type == 1){
      buy_url = "https://www.uuhaodian.com/jd/buy/" + z.item_id + '/';
    }
    htmlstr += '<div class="zk-item">';
    if(coupon_money == 0 && z.price_type == 1){
      htmlstr += '<a href="'+ buy_url +'" target="_blank" title="' + z.title +  '">';
    }
    else{
      htmlstr += '<a href="'+ buy_url +'" title="' + z.title +  '" target="_blank">';
    }
    htmlstr += '<div class="img-area">';
    htmlstr += '<img class="lazy new" data-original="'+ z.pict_url +'" alt="'+z.title +'">';
    htmlstr += '</div>';
    htmlstr += '<p class="title-area">';
    htmlstr +=  z.title +'</p>';
    htmlstr += '<div class="tags-area">'
    htmlstr += '<span class="tag">京东</span>';
    if(z.owner == 'g'){
      htmlstr += '<span class="tag">自营</span>';
    }
    if(coupon_money > 0){
      htmlstr += '<span class="tag c">' + coupon_money + '元券</span>';
    }
    if(z.shop_title.indexOf('旗舰店') > 0){
      htmlstr += '<span class="tag">旗舰店</span>';
    }
    if(z.is_hot > 0){
      htmlstr += '<span class="tag">爆款</span>';
    }
    htmlstr += '</div>'
    htmlstr += '<div class="price-area">';
    if(coupon_money > 0){
      htmlstr += '券后价 ￥ <span class="price">' + z.lowest_coupon_price + '</span>';
    }
    else if(coupon_money == 0 && z.price_type == 2){
      htmlstr += '拼购价 ￥ <span class="price">' + z.lowest_coupon_price + '</span>';
    }
    else if(coupon_money == 0 && z.price_type == 3){
      htmlstr += '秒杀价 ￥ <span class="price">' + z.lowest_coupon_price + '</span>';
    }
    else{
      htmlstr += '现价 ￥ <span class="price">' + z.lowest_price + '</span>';
    }
    htmlstr += '</div>';
    if(coupon_money > 0 && z.price_type == 2){
      htmlstr += '<div class="raw-price-area">拼购价：&yen; '+ z.lowest_price;
    }
    else if(coupon_money > 0 && z.price_type == 3){
      htmlstr += '<div class="raw-price-area">秒杀价：&yen; '+ z.lowest_price;
    }
    else{
      htmlstr += '<div class="raw-price-area">原价：&yen; '+ z.o_price;
    }
    if(z.sales > 0){
      var vv = z.sales > 10000 ? ((z.sales / 10000).toFixed(1) + '万') : z.sales
      htmlstr += '<p class="sold">'+ vv +'人已付款</p>';
    }
    htmlstr += '</div>';
    htmlstr += '</a>';
    htmlstr += '</div>';
  }
  htmlstr += '</div>';
  htmlstr = $(htmlstr);
  obj.append(htmlstr);
  Util.lazyLoad('lazy.new');
  $('.lazy.new').removeClass('new');
}
