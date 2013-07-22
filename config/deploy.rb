
set :application, "chef_rails_template"

require 'capistrano_colors'
require "bundler/capistrano"

# リポジトリ
set :scm, :git
#set :repository, "https://shinyay@bitbucket.org/shinyay/chef_rails_template.git"
set :repository, "."
set :branch, "master"
#set :deploy_via, :remote_cache
set :deploy_via, :copy
set :deploy_to, "/var/www/#{application}"
set :rails_env, "production"

# SSH
set :user, "ec2-user"
set :use_sudo, true
ssh_options[:forward_agent] = true
default_run_options[:pty] = true

# デプロイ先
role :web, "aws"
role :app, "aws"
role :db, "aws", :primary => true

# precompile
load 'deploy/assets'

# cap deploy:setup 後に実行
namespace :setup do
  task :fix_permissions do
    sudo "chown -R #{user}.#{user} #{deploy_to}"
  end
end
after "deploy:setup", "setup:fix_permissions"

# Unicorn用に起動/停止タスクを変更
namespace :deploy do
  task :start, :roles => :app do
    run "cd #{current_path}; bundle exec unicorn_rails -c config/unicorn.rb -E #{rails_env} -D"
  end
  task :restart, :roles => :app do
    if File.exist? "/tmp/unicorn_#{application}.pid"
      run "kill -s USR2 `cat /tmp/unicorn_#{application}.pid`"
    end
  end
  task :stop, :roles => :app do
    run "kill -s QUIT `cat /tmp/unicorn_#{application}.pid`"
  end
end
