class Jidanguo < ApplicationRecord
  self.table_name = 'bxg_products'
end

class JidanguoLink < ApplicationRecord
  self.table_name = 'jidanguo_links'
end

class JidanguoTag < ApplicationRecord
  self.table_name = 'bxg_tags'
end

class JidanguoTagProduct < ApplicationRecord
  self.table_name = 'bxg_tag_products'
end

