require "bundler/capistrano"
require 'thinking_sphinx/deploy/capistrano'

set :application,    "mynewtv2"
#set :scm,            :git
#set :repository,     "git@github.com:blanchma/mynewtv.git"
#set :branch, "master"
#set :deploy_via, :remote_cache

#set :repository,     "matias@mynew.tv:/home/matias/mynewtv2.git" #qm0zwn9x
#set :branch,        "tute"
set :scm,           :subversion
set :repository,    "https://pl3.projectlocker.com/mynewtv/mynewtv2/svn"
set :svn_username,  "tute@mynew.tv"
set :svn_password,  "parmenides"
set :user,           "mynewtv2"
#set :scm_passphrase, "parmenides"
set :deploy_to,      "/home/#{user}/"
set :use_sudo,       false
set :group_writable, false


# set :deploy_via, :remote_cache
#set :deploy_via, :fast_remote_cache
set :copy_exclude, %w(.git doc)

role :web, "mynew.tv"                          # Your HTTP server, Apache/etc
role :app, "mynew.tv"                          # This may be the same as your `Web` server
role :db,  "mynew.tv", :primary => true # This is where Rails migrations will run

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

#before "deploy:update_code", "git:push"
after  "deploy:update_code", "db:symlink"


namespace :db do
  desc "Make symlink for database yaml"
  task :symlink do
    run "ln -nfs #{shared_path}/database.yml #{release_path}/config/database.yml"
    #run "ln -nfs #{shared_path}/rvmrc        #{release_path}/.rvmrc"
  end
end

namespace :git do
  task :push do
    system('git push')
  end
end

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
    #run "sudo god restart resque"
  end
end

namespace :deploy do
  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    run "cd /home/mynewtv2/current && whenever --update-crontab #{application}"
  end
end


task :before_update_code, :roles => [:app] do
  thinking_sphinx.stop
end

task :after_update_code, :roles => [:app] do
  symlink_sphinx_indexes
  thinking_sphinx.configure
  thinking_sphinx.start
end

task :symlink_sphinx_indexes, :roles => [:app] do
  run "ln -nfs #{shared_path}/db/sphinx #{release_path}/db/sphinx"
end


