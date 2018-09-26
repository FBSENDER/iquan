Util.createLanlanCouponList = function(cl,obj,channel,gaPage){
    gaPage = gaPage || '未知';
    var htmlstr = '<div>';
    for(var i=0,len=cl.length;i<len;i++){
        var z = cl[i];
        var re = /activityId=(\w*)/;
        //var buy_url = '/buy/' + z.itemId + '/?activity_id=' + re.exec(z.couponUrl)[1];
        var buy_url = 'http://uu.iquan.net/yh/' + z.itemId + '/#coupon';
        var platform = '',platformPic = '';
        if(z.shopType == 'tmall')
          platform = 2;
        else
          platform = 1;
        htmlstr += '<div class="zk-item">';
        htmlstr += '<a href="'+ buy_url +'">';
        htmlstr += '<div class="img-area">';
        htmlstr += '<div class="bottom-info">';
        htmlstr += '<p data-endtime="'+ z.couponEndTime +'" class="time-count"></p>';
        htmlstr += '</div>';
        htmlstr += '<img data-ga-event="商品_图片:点击:'+ gaPage +'" class="lazy new" data-original="'+ z.coverImage +'" alt="'+z.title +'">';
        htmlstr += '</div>';
        htmlstr += '<p class="title-area elli">';
        if(platform == 1){
            htmlstr += '<i class="i_taobao"></i>';
        }
        else{
            htmlstr += '<i class="i_tmall"></i>';
        }
        htmlstr += '<span class="post-free">包邮</span>';
        htmlstr +=  z.shortTitle +'</p>';
        htmlstr += '<div class="raw-price-area">现价：&yen;'+ z.price +'<p class="sold">已领'+ z.monthSales +'张券</p></div>';
        htmlstr += '<div class="info">';
        htmlstr += '<div class="price-area">';
        htmlstr += '<span class="price">&yen;<em class="number-font">'+ z.nowPrice.toString().split('.')[0] +'</em>';
        htmlstr += '<em class="decimal">'+(z.nowPrice.toString().split('.').length>1?'.'+z.nowPrice.toString().split('.')[1]:'')+'</em><i></i></span>';
        htmlstr += '</div>';
        htmlstr += '<span class="coupon_click">券 ';
        htmlstr += parseInt(z.couponMoney);
        htmlstr += ' 元</span>';
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
    Util.zkItemTimeCount();
}
