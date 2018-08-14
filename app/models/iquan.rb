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

class QxUser < ApplicationRecord
  self.table_name = 'qx_users'
end

class QxUserDetail < ApplicationRecord
  self.table_name = 'qx_user_details'
end

class UuToken < ApplicationRecord
  self.table_name = 'uu_tokens'
end
