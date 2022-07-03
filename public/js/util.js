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
Util.createAliList = function(cl,obj,channel,gaPage){
  gaPage = gaPage || '未知';
  var htmlstr = '<div>';
  for(var i=0,len=cl.length;i<len;i++){
    var z = cl[i];
    htmlstr += '<div class="zk-item">';
    htmlstr += '<a href="/e_detail/'+ z.product_id +'">';
    htmlstr += '<div class="img-area">';
    htmlstr += '<img class="lazy new" data-original="'+ z.product_main_image_url +'" alt="'+z.product_title +'">';
    htmlstr += '</div>';
    htmlstr += '<p class="title-area">';
    htmlstr +=  z.product_title +'</p>';
    htmlstr += '<div class="tags-area">'
    if(z.discount == '0%'){
      var scn = z.second_level_category_name;
      if(scn.length > 20){
        scn = scn.split('&')[0];
      }
      htmlstr += '<span class="tag c">' + scn + '</span>';
    }
    else{
      var scn = z.second_level_category_name;
      if(scn.length > 20){
        scn = scn.split('&')[0];
      }
      htmlstr += '<span class="tag">-' + z.discount + '</span>';
      htmlstr += '<span class="tag c">' + scn + '</span>';
    }
    htmlstr += '</div>'
    htmlstr += '<div class="price-area">';
    htmlstr += 'US $ <span class="price">' + z.sale_price + '</span>';
    htmlstr += '</div>';
    htmlstr += '<div class="raw-price-area"> <span style="text-decoration: line-through">US $'+ z.original_price + '</span>';
    if(z.lastest_volume > 0){
      var vv = z.lastest_volume > 10000 ? ((z.lastest_volume / 10000).toFixed(1) + 'w') : z.lastest_volume
      htmlstr += '<span class="sold">' + vv +' orders</span>'
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
/*! jquery.cookie v1.4.1 | MIT */
!function(a){"function"==typeof define&&define.amd?define(["jquery"],a):"object"==typeof exports?a(require("jquery")):a(jQuery)}(function(a){function b(a){return h.raw?a:encodeURIComponent(a)}function c(a){return h.raw?a:decodeURIComponent(a)}function d(a){return b(h.json?JSON.stringify(a):String(a))}function e(a){0===a.indexOf('"')&&(a=a.slice(1,-1).replace(/\\"/g,'"').replace(/\\\\/g,"\\"));try{return a=decodeURIComponent(a.replace(g," ")),h.json?JSON.parse(a):a}catch(b){}}function f(b,c){var d=h.raw?b:e(b);return a.isFunction(c)?c(d):d}var g=/\+/g,h=a.cookie=function(e,g,i){if(void 0!==g&&!a.isFunction(g)){if(i=a.extend({},h.defaults,i),"number"==typeof i.expires){var j=i.expires,k=i.expires=new Date;k.setTime(+k+864e5*j)}return document.cookie=[b(e),"=",d(g),i.expires?"; expires="+i.expires.toUTCString():"",i.path?"; path="+i.path:"",i.domain?"; domain="+i.domain:"",i.secure?"; secure":""].join("")}for(var l=e?void 0:{},m=document.cookie?document.cookie.split("; "):[],n=0,o=m.length;o>n;n++){var p=m[n].split("="),q=c(p.shift()),r=p.join("=");if(e&&e===q){l=f(r,g);break}e||void 0===(r=f(r))||(l[q]=r)}return l};h.defaults={},a.removeCookie=function(b,c){return void 0===a.cookie(b)?!1:(a.cookie(b,"",a.extend({},c,{expires:-1})),!a.cookie(b))}});
