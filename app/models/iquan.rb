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

class CidKeywordRelation < ApplicationRecord
  self.table_name = 'iquan_coupon_keyword_relations'
end

class Shop < ApplicationRecord
  self.table_name = 'iquan_shops'
end

class ShopCoupon < ApplicationRecord
  self.table_name = 'iquan_shop_coupons'
end

class CouponSuggestion < ApplicationRecord
  self.table_name = 'iquan_coupon_suggestions'
end
