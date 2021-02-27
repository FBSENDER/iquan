class ComKeyword < ApplicationRecord
  self.table_name = 'com_keywords'
end

class ComShop < ApplicationRecord
  self.table_name = 'com_shops'
end

class Shop < ApplicationRecord
  self.table_name = 'iquan_shops'
end

class Detail < ApplicationRecord
  self.table_name = "dataoke_17430_details"
end

class DtkProduct < ApplicationRecord
  self.table_name = "dataoke_products"
end
