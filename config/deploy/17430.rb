set :application, '17430'
set :branch, '17430'
set :deploy_to, '/home/work/17430'

namespace :deploy do

  after :finished, :restart_puma do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      execute "cd #{deploy_to} && cp shared/config/database.yml current/config/database.yml && cp shared/config/secrets.yml current/config/secrets.yml && cp shared/app/controllers/diyquan_controller.rb current/app/controllers/"
      execute "docker tag 17430_docker 17430_docker:old || echo 1"
      execute "cd #{deploy_to}/current && docker build -t 17430_docker . --no-cache"
      execute "docker kill 17430_1 || echo 1"
      execute "docker rm 17430_1 || echo 1"
      execute "docker run -v /tmp/17430/17430_1/:/tmp/ -v /home/work/17430/shared/public/assets/:/usr/src/app/public/assets/ -v /home/work/17430/shared/log_1/:/usr/src/app/log/ -d --name 17430_1 17430_docker"
      execute "docker cp /home/work/17430/shared/simsun.ttc 17430_1:/usr/share/fonts/"

    end
  end
end

# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:

#server '106.14.4.158', user: 'work', roles: %w{web}
server '47.52.107.131', user: 'work', roles: %w{web}
# server 'example.com', user: 'deploy', roles: %w{app web}, other_property: :other_value
# server 'db.example.com', user: 'deploy', roles: %w{db}



# role-based syntax
# ==================

# Defines a role with one or multiple servers. The primary server in each
# group is considered to be the first unless any  hosts have the primary
# property set. Specify the username and a domain or IP for the server.
# Don't use `:all`, it's a meta role.

# role :app, %w{deploy@example.com}, my_property: :my_value
# role :web, %w{user1@primary.com user2@additional.com}, other_property: :other_value
# role :db,  %w{deploy@example.com}
role :web, %w{work@47.52.107.131}

server '47.52.107.131',
  user: 'work',
  roles: %w{web},
  ssh_options:{
    auth_methods: %w(publickey)
  }



# Configuration
# =============
# You can set any configuration variable like in config/deploy.rb
# These variables are then only loaded and set in this stage.
# For available Capistrano configuration variables see the documentation page.
# http://capistranorb.com/documentation/getting-started/configuration/
# Feel free to add new variables to customise your setup.



# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult the Net::SSH documentation.
# http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# The server-based syntax can be used to override options:
# ------------------------------------
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
