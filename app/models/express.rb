class AliCategory < ApplicationRecord
  self.table_name = 'ali_categories'
end

class AliBrand < ApplicationRecord
  self.table_name = 'ali_brands'
end

class AliCategoryAttr < ApplicationRecord
  self.table_name = 'ali_category_attr_jsons'
end

class AliKeyword < ApplicationRecord
  self.table_name = 'ali_keywords'
end

class AliCB< ApplicationRecord
  self.table_name = 'ali_category_brand_relations'
end

class AliCK < ApplicationRecord
  self.table_name = 'ali_category_keyword_relations'
end
