set :application, 'telluric-wedding'
set :repo_url, 'git@github.com:jujudellago/telluric-wedding.git'

# Branch options
# Prompts for the branch name (defaults to current branch)
#ask :branch, -> { `git rev-parse --abbrev-ref HEAD`.chomp }

# Hardcodes branch to always be master
# This could be overridden in a stage config file
set :branch, :master
@secrets_yml ||= YAML.load_file(File.expand_path("secrets.yml", __dir__))




# Use :debug for more verbose output when troubleshooting
set :log_level, :info

# Apache users with .htaccess files:
# it needs to be added to linked_files so it persists across deploys:
#set :linked_files, fetch(:linked_files, []).push('.env', 'web/.htaccess','web/app/advanced-cache.php','web/app/db.php','web/app/object-cache.php')
set :linked_files, fetch(:linked_files, []).push('.env', 'web/.htaccess')



set :linked_dirs, fetch(:linked_dirs, []).push('web/app/uploads')



namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :service, :nginx, :reload
    end
  end
end

# The above restart task is not run by default
# Uncomment the following line to run it on deploys if needed
# after 'deploy:publishing', 'deploy:restart'

namespace :deploy do
  desc 'Update WordPress template root paths to point to the new release'
  task :update_option_paths do
    on roles(:app) do
      within fetch(:release_path) do
        if test :wp, :core, 'is-installed'
          [:stylesheet_root, :template_root].each do |option|
            # Only change the value if it's an absolute path
            # i.e. The relative path "/themes" must remain unchanged
            # Also, the option might not be set, in which case we leave it like that
            value = capture :wp, :option, :get, option, raise_on_non_zero_exit: false
            if value != '' && value != '/themes'
              execute :wp, :option, :set, option, fetch(:release_path).join('web/wp/wp-content/themes')
            end
          end
        end
      end
    end
  end
end

# The above update_option_paths task is not run by default
# Note that you need to have WP-CLI installed on your server
# Uncomment the following line to run it on deploys if needed
# after 'deploy:publishing', 'deploy:update_option_paths'




# The Roots theme by default does not check production assets into Git, so
# they are not deployed by Capistrano when using the Bedrock stack. The
# following will compile and deploy those assets. Copy this to the bottom of
# your config/deploy.rb file.

# Based on information from this thread:
# http://discourse.roots.io/t/capistrano-run-grunt-locally-and-upload-files/2062/7
# and specifically this gist from christhesoul:
# https://gist.github.com/christhesoul/3c38053971a7b786eff2

# First we need to set some variables so we know where things are. You should
# only have to modify :theme_path here, :local_app_path and :local_theme_path
# are set from that.

set :local_app_path, Pathname.new(File.dirname(__FILE__)).join('../')


# Next we list the production assets we want to deploy. We could change things
# around so that all our production assets are generated into a single
# directory and upload that, but it would involve touching a lot of things.
# Listing them each explicitly keeps our changes to just the deployment
# configuration.

# or define in block




namespace :deploy do
  task :set_rights do
    on roles(:web) do
      execute :find, release_path.to_s, ' -type d -name  "*" -exec chmod 755 {} \;'
      execute :find, release_path.to_s, ' -type f -name  "*" -exec chmod 644 {} \;'


      execute :find, release_path.to_s+'/web/app/themes/bridge','  -type d -name  "js" -exec  chmod 777 {} \;'
      execute :find, release_path.to_s+'/web/app/themes/bridge','  -type d -name  "css" -exec  chmod 777 {} \;'

      # execute "/bin/sh /set_staging.sh"
    end
  end
end

after "deploy:updated", "deploy:set_rights"
