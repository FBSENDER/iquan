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
      htmlstr += '<a href="/detail/x_'+ z.item_id +'?coupon_money=' + coupon_money + '">';
    }
    else{
      htmlstr += '<a href="/detail/x_'+ z.item_id +'">';
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
    var buy_url = "/detail/y_" + z.item_id;
    if(coupon_money == 0 && z.price_type == 1){
      buy_url = "/detail/y_" + z.item_id;
    }
    htmlstr += '<div class="zk-item">';
    if(coupon_money == 0 && z.price_type == 1){
      htmlstr += '<a href="'+ buy_url +'" target="_blank" title="' + z.title +  '">';
    }
    else{
      htmlstr += '<a href="'+ buy_url +'" title="' + z.title +  '">';
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
Util.createPddList = function(cl,obj,channel,gaPage){
  gaPage = gaPage || '未知';
  var htmlstr = '<div>';
  for(var i=0,len=cl.length;i<len;i++){
    var z = cl[i];
    var coupon_money = z.couponMoney ? parseInt(z.couponMoney) : 0;
    var zhe = (parseFloat(z.nowPrice) * 10.0 / parseFloat(z.price)).toFixed(1);
    var buy_url = '/detail/z_' + z.itemId;
    htmlstr += '<div class="zk-item">';
    htmlstr += '<a href="'+ buy_url +'" title="'+ z.title + '">';
    htmlstr += '<div class="img-area">';
    htmlstr += '<img class="lazy new" data-original="'+ z.coverImage +'" alt="'+z.title +'">';
    htmlstr += '</div>';
    htmlstr += '<p class="title-area">';
    htmlstr +=  z.shortTitle +'</p>';
    htmlstr += '<div class="tags-area">'
    htmlstr += '<span class="tag">拼多多</span>';
    var tag_count = 1;
    if(coupon_money > 0){
      htmlstr += '<span class="tag c">' + coupon_money + '元券</span>';
      tag_count += 1;
    }
    if(tag_count < 3 && z.activityTags != null && z.activityTags.includes(4)){
      htmlstr += '<span class="tag">秒杀</span>';
      tag_count += 1;
    }
    if(tag_count < 3 && z.activityTags != null && z.activityTags.includes(7)){
      htmlstr += '<span class="tag">百亿补贴</span>';
      tag_count += 1;
    }
    if(tag_count < 3 && z.activityTags != null && z.activityTags.includes(21)){
      htmlstr += '<span class="tag">金牌卖家</span>';
      tag_count += 1;
    }
    if(tag_count < 3 && z.shopName.indexOf('旗舰店') > 0){
      htmlstr += '<span class="tag">旗舰店</span>';
      tag_count += 1;
    }
    htmlstr += '</div>'
    htmlstr += '<div class="price-area">';
    if(coupon_money > 0){
      htmlstr += '券后价 ￥ <span class="price">' + z.nowPrice + '</span>';
    }
    else{
      htmlstr += '折扣价 ￥ <span class="price">' + z.nowPrice + '</span>';
    }
    htmlstr += '</div>';
    htmlstr += '<div class="raw-price-area">原价：&yen;'+ z.price;
    if(z.monthSales != '0'){
      htmlstr += '<p class="sold">'+ z.monthSales +'人已付款</p>';
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
/*! jquery.cookie v1.4.1 | MIT */
!function(a){"function"==typeof define&&define.amd?define(["jquery"],a):"object"==typeof exports?a(require("jquery")):a(jQuery)}(function(a){function b(a){return h.raw?a:encodeURIComponent(a)}function c(a){return h.raw?a:decodeURIComponent(a)}function d(a){return b(h.json?JSON.stringify(a):String(a))}function e(a){0===a.indexOf('"')&&(a=a.slice(1,-1).replace(/\\"/g,'"').replace(/\\\\/g,"\\"));try{return a=decodeURIComponent(a.replace(g," ")),h.json?JSON.parse(a):a}catch(b){}}function f(b,c){var d=h.raw?b:e(b);return a.isFunction(c)?c(d):d}var g=/\+/g,h=a.cookie=function(e,g,i){if(void 0!==g&&!a.isFunction(g)){if(i=a.extend({},h.defaults,i),"number"==typeof i.expires){var j=i.expires,k=i.expires=new Date;k.setTime(+k+864e5*j)}return document.cookie=[b(e),"=",d(g),i.expires?"; expires="+i.expires.toUTCString():"",i.path?"; path="+i.path:"",i.domain?"; domain="+i.domain:"",i.secure?"; secure":""].join("")}for(var l=e?void 0:{},m=document.cookie?document.cookie.split("; "):[],n=0,o=m.length;o>n;n++){var p=m[n].split("="),q=c(p.shift()),r=p.join("=");if(e&&e===q){l=f(r,g);break}e||void 0===(r=f(r))||(l[q]=r)}return l};h.defaults={},a.removeCookie=function(b,c){return void 0===a.cookie(b)?!1:(a.cookie(b,"",a.extend({},c,{expires:-1})),!a.cookie(b))}});
