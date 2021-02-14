class ProductClick < ApplicationRecord
  self.table_name = 'iquan_product_clicks'
end

class ICookie < ApplicationRecord
  self.table_name = 'iquan_cookies'
end

class Link < ApplicationRecord
  self.table_name = 'iquan_links'
end

class AppDownload < ApplicationRecord
  self.table_name = 'iquan_app_downloads'
end

class Page < ApplicationRecord
  self.table_name = 'iquan_pages'
end

class KeywordTbku < ApplicationRecord
  self.table_name = 'iquan_keyword_tbku'
end

class SuggestKeyword < ApplicationRecord
  self.table_name = 'iquan_suggest_keywords'
end

class SuggestKeywordNew < ApplicationRecord
  self.table_name = 'iquan_suggest_keywords_new'
end

class CidKeywordRelation < ApplicationRecord
  self.table_name = 'iquan_coupon_keyword_relations'
end

class Shop < ApplicationRecord
  self.table_name = 'iquan_shops'
end

class ShopCoupon < ApplicationRecord
  self.table_name = 'iquan_shop_coupons'
end

class Product < ApplicationRecord
  self.table_name = 'iquan_products'
end

class CouponSuggestion < ApplicationRecord
  self.table_name = 'iquan_coupon_suggestions'
end

class CateCollection < ApplicationRecord
  self.table_name = 'iquan_cate_collections'
end

class SearchResult < ApplicationRecord
  self.table_name = 'iquan_search_results'
end

class SearchUrlLog < ApplicationRecord
  self.table_name = 'iquan_search_item_url_logs'
end

class QuickSearchLog < ApplicationRecord
  self.table_name = 'iquan_quick_search_logs'
end

class Tag < ApplicationRecord
  self.table_name = 'iquan_tags'
end

class Banner < ApplicationRecord
  self.table_name = 'iquan_banners'
end

class OutLink < ApplicationRecord
  self.table_name = 'iquan_outlinks'
end

class TbKeyword < ApplicationRecord
  self.table_name = 'qixiu_keywords'
end

class PeishiProduct < ApplicationRecord 
  self.table_name = 'peishi_products'
end

class MeizhuangProduct < ApplicationRecord
  self.table_name = 'meizhuang_products'
end

class JdShop < ApplicationRecord 
  self.table_name = 'jd_shop_seo_jsons'
end

class DtkProduct < ApplicationRecord
  self.table_name = 'dataoke_products'
end

class DtkFc < ApplicationRecord
  self.table_name = 'dataoke_friend_circles'
end
