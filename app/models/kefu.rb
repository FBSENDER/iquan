class KefuClick < ApplicationRecord
  self.table_name = 'swan_kefu_clicks'
end

class KefuMessage < ApplicationRecord
  self.table_name = 'swan_kefu_messages'
end

class KefuToken < ApplicationRecord
  self.table_name = 'swan_tokens'
end

class SwanUser < ApplicationRecord
  self.table_name = 'swan_uu_users'
end
