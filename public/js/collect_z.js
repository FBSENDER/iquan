!function(t,e){function o(t){return t=(t+"").toString(),encodeURIComponent(t).replace(/!/g,"%21").replace(/'/g,"%27").replace(/\(/g,"%28").replace(/\)/g,"%29").replace(/\*/g,"%2A").replace(/%20/g,"+")}function n(t){return t?t.url?t.path?t.cookieName?t.gender?!1:(console.error("性别判断没有输入"),!0):(console.error("请填写配置选项：当前页面种植下去的cookie名"),!0):(console.error("请填写配置选项：页面刷新埋点路径path"),!0):(console.error("请填写配置选项：上报url"),!0):(console.error("请填写配置"),!0)}function r(t,e){var o=null,n="?_path=9001.CA.0",r="?_path=9001.CH.",i="?_path=9001.SE.",c=e.pathname,s=(e.href,e.search);if("/"==c||"/saber/index/"==c||"/saber/index"==c){var h=l(s);console.log("index"),(void 0==h.cid||""==h.cid)&&(o=n,console.log("index-cid=null")),h.cid&&/[0-9]/.test(h.cid)&&(o="?_path=9001.CA."+h.cid,console.log("index-cid"))}if("/saber/list/"==c||"/saber/list"==c){var h=l(s);if(!h.type)return console.log("不存在type"),!1;h.search?(console.log("list-search"),o=i+"0"):(console.log("list"),o=r+h.type)}if("/saber/wall"==c||"/saber/wall"==c){var h=l(s);h.id&&h._path&&a(h._path.split("."))&&(console.log("wall"),o="?_path="+h._path)}if("/saber/search"==c||"/saber/search/"==c){var h=l(s);(h.search||void 0!=h.search)&&a(h._path.split("."))&&(console.log("search"),o="?_path="+h._path)}if("/saber/detail"==c||"/saber/detail/"==c){var h=l(s);h.activityId&&h.itemId&&a(h._path.split("."))&&(console.log("detail"),o="?_path="+h._path)}if("/h5/collection/detail"==c||"/h5/collection/detail/"==c){var h=l(s);h.id&&a(h._path.split("."))&&(console.log("h5"),o="?_path="+h._path)}return o}function i(t){var e="?"+t,o=t.split("=");if("_path"==!o[0])return!1;var n=o[1].split(".");return a(n)?e:!1}function a(t){var e=t[0],o=t[1],n=t[2];return 9001!=e?!1:/[A-Z]/.test(o)&&/[0-9]/.test(n)?!0:!1}function l(t){var e={};return t.replace(/[?&]+([^=&]+)=([^&]*)/gi,function(t,o,n){e[o]=n}),e}function c(t,e,n,a,l,c){var s=n,h={onload:function(t,e){return r(t,e)},event:function(t,e){return i(t,e)}},u=h[c](e,a);if(!u)return!1;s&&(u=u+"&u="+s);var p=new Image;return function(){p.src=t+u+"&href="+o(location.href)+"&gender="+l+"&time="+(new Date).getTime()}()}function s(t){return n(t)?!1:(this.url=t.url,this.path="/"==t.path?"":t.path,this.cookieName=t.cookieName,this.gender=t.gender,this.init())}function h(t){for(var e=0;e<t.length;e++)if(t[e].getAttribute&&t[e].getAttribute("data-collection"))return t[e].getAttribute("data-collection");return!1}s.prototype.init=function(){return function(){this.allDocumentClick(),this.onLoad()}.bind(this)()},s.prototype.allDocumentClick=function(){return e.addEventListener("click",function(e){var o=t.location,n=h(e.path);n&&c(this.url,n,this.cookieName,o,this.gender,"event")}.bind(this),!1)},s.prototype.onLoad=function(){var e=t.location;c(this.url,this.path,this.cookieName,e,this.gender,"onload")},s.prototype.Event=function(e){var o=t.location;c(this.url,e,this.cookieName,o,this.gender,"event")},t.Collection=s}(window,document);