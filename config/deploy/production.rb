set :stage, :staging

# Simple Role Syntax
# ==================
#role :app, %w{deploy@example.com}
#role :web, %w{deploy@example.com}
#role :db,  %w{deploy@example.com}

# Extended Server Syntax
# ======================
server 'bqpm.ftp.sharedbox.com', user: 'bqpm_yabonew', roles: %w{web app db}

set :tmp_dir, "/home/clients/d9e7a0ab00bb20eac180d94da2fe2de6/tmp"


set :deploy_to, -> { "/home/clients/d9e7a0ab00bb20eac180d94da2fe2de6/telluric" }

#set :linked_files, fetch(:linked_files, []).push('.env','web/app/db.php', 'web/app/object-cache.php', 'web/app/advanced-cache.php')

#SSHKit.config.command_map[:composer] = "php-7.3 /home/clients/d9e7a0ab00bb20eac180d94da2fe2de6/bin/composer/composer.phar"

SSHKit.config.command_map[:wp] ="~/bin/wp.sh"

# you can set custom ssh options
# it's possible to pass any option but you need to keep in mind that net/ssh understand limited list of options
# you can see them in [net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start)
# set it globally
#  set :ssh_options, {
#    keys: %w(~/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }

fetch(:default_env).merge!(wp_env: :production)

set :wpcli_remote_url, @secrets_yml['production_url']
set :wpcli_local_url, @secrets_yml['dev_url']

set :local_tmp_dir, '/Users/juju/tmp'
set :wpcli_backup_db, true
set :wpcli_local_db_backup_dir, 'config/backups'
set :wpcli_local_uploads_dir, 'web/app/uploads/'
set :wpcli_remote_uploads_dir, "#{shared_path.to_s}/web/app/uploads/"






