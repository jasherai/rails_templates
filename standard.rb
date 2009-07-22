##############################################################
# Standard Rails Application Template
# Author: Ben Hughes
# 
# Known Issues
# * Gem dependencies should really be in test environment
# 
##############################################################


## Configuration
EXCEPTION_EMAIL = "me@benhughes.name"

application_name = ask("\n\nName of Application (GitHub Product) [project]: ")
application_name = 'product' if application_name.blank?

application_domain = ask("\nDomain Name of Application [server.com]: ")
application_domain = 'server.com' if application_domain.blank?

puts "Configuring Standard Rails Applcation #{application_name}"

run "echo '= #{application_name}' > README"

## Environment
environment("config.action_controller.session = { :key => '_#{application_name}_session', :secret => '#{Digest::MD5.hexdigest(Time.now.to_s + rand.to_s)}' }")


## Standard Plugins
plugin 'message_block', :git => "git://github.com/railsgarden/message_block.git"
plugin 'exception_notification', :git => "git://github.com/rails/exception_notification.git"
plugin 'jrails', :git => "git://github.com/aaronchi/jrails.git"
plugin 'seed-fu', :git => "git://github.com/mbleigh/seed-fu.git"

## Standard Gems
gem 'mislav-will_paginate', :version => '~> 2.2.3', :lib => 'will_paginate', :source => 'http://gems.github.com'

rake("gems:install", :sudo => true)

## Testing Frameworks
testing_framework = ask("\n\nTesting Framework (rspec, shoulda) [rspec]: ")
testing_framework = 'rspec' if testing_framework.blank?

case testing_framework
  when 'shoulda'
    gem "thoughtbot-shoulda", :lib => "shoulda", :source => "http://gems.github.com"
    gem "thoughtbot-factory_girl", :lib => "factory_girl", :source => "http://gems.github.com"
    gem "faker"
    gem "rcov"
    gem "mocha"
    
    rake("gems:install", :sudo => true)
    
    inside('test') do
      run "mkdir factories"
    end
    
    plugin 'coulda', :git => "git://github.com/dancroak/coulda.git"
    
  when 'rspec'
    gem "rspec", :lib => "spec"
    gem "rspec-rails", :lib => "spec/rails"
    gem "cucumber", :source => "http://gems.github.com"
    gem "thoughtbot-factory_girl", :lib => "factory_girl", :source => "http://gems.github.com"
    gem "faker"
    gem "thoughtbot-shoulda", :lib => "shoulda", :source => "http://gems.github.com"
    gem "rcov"
    gem "mocha"
    
    rake("gems:install", :sudo => true)
    
    inside('spec') do
      run "mkdir factories"
    end
    
    generate :rspec
  
end



initializer 'time_formats.rb', <<-END
ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.update(
  :compact => '%Y.%m.%d',
  :conventional => '%m/%d/%Y',
  :cc_expiration => '%Y.%m',
  :month_year => '%b %Y'
)

ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.update(
  :compact => '%Y.%m.%d %H:%M:%S %p',
  :conventional => '%m/%d/%Y %H:%M:%S %p',
  :month_year => '%b %Y',
  :conventional_time => '%I:%M %p',
  :compact_time => '%I:%M %p'
)
END

initializer 'quick_scopes.rb', <<-END
class ActiveRecord::Base
  named_scope :order, lambda { |order|
    { :order => order }
  }
  
  named_scope :limit, lambda { |limit|
    { :limit => limit }
  }
  
  named_scope :with, lambda { |*include|
    { :include => include.size == 1 ? include[0] : include }
  }
  
  named_scope :where, lambda { |*conditions|
    { :conditions => conditions.size == 1 ? conditions[0] : conditions }
  }
  
  named_scope :offset, lambda { |offset|
    { :offset => offset }
  }
end
END

initializer 'action_mailer_configs.rb', <<-END
ActionMailer::Base.smtp_settings = {
  :address => "localhost",
  :port => 25
}
END

initializer 'exception_notification.rb', <<-END
ExceptionNotifier.exception_recipients = %w(#{EXCEPTION_EMAIL})
ExceptionNotifier.email_prefix = "[RAILS_EXCEPTION - #{application_name}] "
END

initializer 'field_errors.rb', <<-END
ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  "<span class=\\"field-with-errors\\">\#{html_tag}</span>"
end
END

file 'app/views/layouts/application.html.erb', <<-END
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
  <meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
  <meta name="author" content="CSDVRS" />
  
  <title>#{application_name}</title>
  
  <link rel="stylesheet" type="text/css" href="css/reset.css" media="screen" />
	<link rel="stylesheet" type="text/css" href="css/text.css" media="screen" />
	<link rel="stylesheet" type="text/css" href="css/grid.css" media="screen" />
	<link rel="stylesheet" type="text/css" href="css/layout.css" media="screen" />
	<link rel="stylesheet" type="text/css" href="css/nav.css" media="screen" />
	<!--[if IE 6]><link rel="stylesheet" type="text/css" href="css/ie6.css" media="screen" /><![endif]-->
	<!--[if IE 7]><link rel="stylesheet" type="text/css" href="css/ie.css" media="screen" /><![endif]-->
  
  <%= stylesheet_link_tag 'application', 'message_block' %>
  <%= javascript_include_tag :defaults %>
  
  <%= yield :head %>
</head>

<body class="<%= body_class %>">
  
  <div id="wrapper">
    <div id="inner-wrapper">
      
      <div id="content">
        <%= yield %>
      </div>
      
    </div>
  </div>
  
</body>
</html>
END


file 'public/stylesheets/application.css', <<-END
/*** Custom Styles ***/
END

file 'app/helpers/application_helper.rb', %q{
module ApplicationHelper
  def body_class
    "#{controller.controller_name} #{controller.controller_name}-#{controller.action_name}"
  end
end
}

file 'app/controllers/application_controller.rb', %q{
class ApplicationController < ActionController::Base
  protect_from_forgery
  filter_parameter_logging :password
  
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  
  
  protected
  
  def record_not_found
    render :file => File.join(RAILS_ROOT, 'public', '404.html'), :status => 404
  end
end
}



### Capistrano
capify!

file "config/deploy.rb", <<-END
set :stages, %w(staging production)
set :default_stage, 'staging'

require 'capistrano/ext/multistage'

set :application, "#{application_name}"
set :domain, "#{application_domain}"

set :scm, :git
set :repository, "git@github.com:railsgarden/\#{application}.git"
set :deploy_via, :remote_cache
set :scm_verbose, true
set :use_sudo, false
set :ssh_options, {:forward_agent => true}

set :deploy_to, "/var/www/\#{domain}"
set :user, "\#{application}"

set :shared_paths, %w(
  config/database.yml
)

# Deployment
namespace :deploy do
  desc "Restart Passenger"
  task :restart, :roles => :app do
    run "touch \#{current_path}/tmp/restart.txt"
  end
  
  # ErrorDocument 503 /503.html
  # RewriteEngine on
  # RewriteCond %{DOCUMENT_ROOT}/../tmp/stop.txt -f
  # RewriteCond %{DOCUMENT_ROOT}/%{REQUEST_FILENAME} !-f
  # RewriteRule ^(.*)$ /$1 [R=503,L]
  
  desc "Stop Passenger"
  task :stop, :roles => :app do
    run "touch \#{current_path}/tmp/stop.txt"
  end

  desc "Start (or un-stop) Passenger"
  task :start, :roles => :app do
    run "rm -f \#{current_path}/tmp/stop.txt"
  end
  
  task :symlink_shared do 
    ["/config/database.yml", "/tmp/cache"].each do |path|
      run "ln -nfs \#{shared_path}\#{path} \#{release_path}\#{path}"
    end
  end
  
  task :migrate_database, :roles => [:db] do
    run "cd \#{release_path} && rake db:migrate RAILS_ENV=\#{rails_env}"
  end
  
  after 'deploy:symlink', 'deploy:symlink_shared'
  after 'deploy:symlink', 'deploy:migrate_database'
end

# Database & Asset Synchronization
namespace :pull do
  desc "Mirrors the remote shared public directory with your local copy, doesn't download symlinks"
  task :shared_assets do
    if shared_host
      [].each do |shared_assets|
        run_locally("rsync --recursive --times --rsh=ssh --compress --human-readable --progress \#{user}@\#{shared_host}:\#{shared_path}/\#{shared_assets} \#{shared_assets}")
      end
    else
      puts "shared_host must be defined"
    end
  end
  
  desc "Dump remote production database into tmp/, rsync file to local machine, import into local development database"
  task :database do
    # First lets get the remote database config file so that we can read in the database settings
    get("\#{shared_path}/config/database.yml", "tmp/database.yml")
    
    # load the production settings within the database file
    remote_settings = YAML::load_file("tmp/database.yml")[rails_env]
    
    # we also need the local settings so that we can import the fresh database properly
    local_settings = YAML::load_file("config/database.yml")["development"]
    
    # dump the production database and store it in the current path's tmp directory. 
    # I chose to use the same filename everytime so that it would just overwrite the same file rather than 
    # creating a timestamped file.  If you want to use this to create backups then I would recommend putting 
    # something like Time.now in the filename and not storing it in the tmp directory
    run "mysqldump -u'\#{remote_settings["username"]}' -p'\#{remote_settings["password"]}' --opt -h'\#{remote_settings["host"]}' '\#{remote_settings["database"]}' > \#{current_path}/tmp/production-\#{remote_settings["database"]}-dump.sql"
    
    # run_locally is a method provided by capistrano to run commands on your local machine. Here we are just rsyncing the remote database dump with the local copy of the dump
    run_locally("rsync --times --rsh=ssh --compress --human-readable --progress \#{user}@\#{shared_host}:\#{current_path}/tmp/production-\#{remote_settings["database"]}-dump.sql tmp/production-\#{remote_settings["database"]}-dump.sql")
    
    # now that we have the upated production dump file we should use the local settings to import this db.  
    run_locally("mysql -u\#{local_settings["username"]} \#{"-p\#{local_settings["password"]}" if local_settings["password"]} \#{local_settings["database"]} < tmp/production-\#{remote_settings["database"]}-dump.sql")
  end
  
  desc "Pulls down database and shared assets"
  task :all do
  end
  
  after 'pull:all', 'pull:database'
  after 'pull:all', 'pull:shared_assets'
end

END

file "config/deploy/staging.rb", <<-END
role :app, "stage.#{application_domain}"
role :web, "stage.#{application_domain}"
role :db, "stage.#{application_domain}", :primary => true

set :rails_env, "staging"
set :branch, "master"
set :shared_host, "stage.#{application_domain}"
END

file "config/deploy/production.rb", <<-END
role :app, "#{application_domain}"
role :web, "#{application_domain}"
role :db, "#{application_domain}", :primary => true

set :rails_env, "production"
set :branch, "production"
set :shared_host, "#{application_domain}"
END

run "cp config/environments/production.rb config/environments/staging.rb"


### File Cleanup
run "rm public/index.html"
%w(controls dragdrop effects prototype).each do |file|
  run "rm public/javascripts/#{file}.js"
end


### Git Initialization
git :init

file ".gitignore", <<-END
.DS_Store
log/*.log
tmp/**/*
config/database.yml
db/*.sqlite3
coverage
END

run 'find . \( -type d -empty \) -and \( -not -regex ./\.git.* \) -exec touch {}/.gitignore \;'
run "cp config/database.yml config/database.example.yml"

git :add => "."
git :commit => "-m 'initial commit'"

if yes?("\n\nDo you want to push this to GitHub (yes, no) [no]? ")
  github_username = ask('GitHub Username [railsgarden]: ')
  github_username = 'railsgarden' if github_username.blank?
  
  git :remote => "add origin git@github.com:#{github_username}/#{application_name}.git"
  git :push => "origin master"
  
  git :checkout => '-b production'
  git :push => "origin production"
end


puts "All Done!"
puts "Please remember to copy stylesheets and images to your Rails application!"






