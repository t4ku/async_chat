set :application, "tascal"
set :repository,  "git@github.com:t4ku/async_chat.git"


set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :user,:labo_admin
set :use_sudo,true
set :port,9122
default_run_options[:pty] = true # "sorry, you must have a tty to run sudo"
# require 

set :deploy_to, "/home/labo_admin/apps/async_chat/tascal"

role :web, "labo"                          # Your HTTP server, Apache/etc
role :app, "labo"                          # This may be the same as your `Web` server
role :db,  "labo", :primary => true        # This is where Rails migrations will run
#role :db,  "your slave db-server here"

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
  task :migrate do
    run "ln -nfs #{shared_path}/production.sqlite3 #{current_path}/tascal/db/production.sqlite3"
    run "cd #{File.join(current_path,'tascal')};rake db:migrate RAILS_ENV=production"
  end
  
  task :start_mongrel do
      run "cd #{File.join(current_path,'tascal')};mongrel_rails start -d -e production -p 3001"
  end
  
  task :stop_mongrel do
      run "cd #{File.join(current_path,'tascal')};mongrel_rails stop"
  end
  
  task :start_thin do
    # stream
    run "cd #{File.join(current_path,'stream')};thin -C config.yml -d start"
  end

  task :stop_thin do
    # stream
    run "cd #{File.join(current_path,'stream')};#{sudo} kill `cat #{File.join(current_path,'stream')}/tmp/pids/thin.pid`"
  end

  task :start_nginx do
      run "#{sudo} /usr/local/nginx/sbin/nginx"
  end
  
  task :stop_nginx do
    run "#{sudo} kill `cat /usr/local/nginx/logs/nginx.pid`"
  end
  
  task :start,:roles => :app do
    start_nginx
    start_thin
    start_mongrel
  end
  
  task :stop,:roles => :app do
    stop_nginx
    stop_thin
    stop_mongrel
  end
  
  
#   task :start do ; end
#   task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    stop
    start
  end
end