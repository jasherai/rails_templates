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
plugin 'exception_notifier', :git => "git://github.com/rails/exception_notification.git"
plugin 'jrails', :git => "git://github.com/aaronchi/jrails.git"

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


file 'app/views/layouts/application.html.erb', <<-END
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
  <meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
  <meta name="author" content="CSDVRS" />
  
  <title>#{application_name}</title>
  
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
/*** Browser Resets ***/

html, body, ul, ol, li, dl, p, pre, dd, blockquote, 
h1, h2, h3, h4, h5, h6, a, form, label, fieldset, address {
	margin: 0;
	padding: 0;
	border: 0;
}

form { margin-bottom: 0; display: inline; }
img { border: 0; }


/*** Main Structural Elements ***/

body {
	font-family: Georgia, Verdana, Arial, Helvetica, sans-serif;
	font-size: 100.01%;
	background: #660000;
	padding: 0;
	margin: 0;
}

#wrapper {
	font-size: 0.8em;
	line-height: 1.4em;
	width: 80%;
	margin: 10px auto 20px auto;
	padding: 10px;
	background: #990000;
}

#inner-wrapper {
	background: #FFFFFF;
	padding: 10px;
	border: 1px solid #999999;
}

#content {
	margin: 8px;
}


/*** Text ***/

a:link { color: #990000; text-decoration: underline; }
a:visited { color: #990000; text-decoration: underline; }
a:hover { color: #990000; text-decoration: none; }

h1, h2, h3, h4, h5, h6 {
	font-family: Georgia, Verdana, Arial, sans-serif;
	padding: 0;
	margin-bottom: 0.8em;
	font-weight: normal;
	margin-top: 0px;
	font-weight: normal;
}

h1 {
	font-size: 1.7em;
	font-weight: normal;
	color: #990000;
	line-height: 1.1em;
	border-bottom: 1px dashed #990000;
	margin-bottom: 0.6em;
}

h2 {
	color: #330000;
	font-size: 1.4em;
	font-weight: normal;
	margin-bottom: 0.6em;
}
h2 span {
	font-size: 0.8em;
	color: #666666;
}
h2 a:link { color: #000000; text-decoration: none; }
h2 a:visited { color: #000000; text-decoration: none; }
h2 a:hover { color: #000000; text-decoration: underline; }

h3 {
	color: #330000;
	font-size: 1.1em;
	font-weight: bold;
	margin-bottom: 0.3em;
}

h4 {
	color: #330000;
	font-weight: bold;
	margin-bottom: 0.3em;
}

p {
	margin-bottom: 1.1em;
}

blockquote {
	border: 1px dashed #CDCDCD;
	background: #F2F2F2;
	padding: 1em;
	margin-bottom: 1.5em;
}

blockquote p {
	margin-bottom: 0;
}

small {
	font-size: 0.8em;
}

cite {
  font-size: 0.9em;
  color: #666666;
  font-style: normal;
}

.microtext {
	font-size: 0.8em;
}

.fieldinfo {
	font-size: 0.8em;
	padding-bottom: 0.3em;
}

sup {
	position: relative;
	bottom: 0.3em;
	vertical-align: baseline;
}

sub {
	position: relative;
	bottom: -0.2em;
	vertical-align: baseline;
}

hr {
	clear: left;
	background-color: #FFFFFF;
	border: none;
	border-bottom: 1px dashed #990000;
	margin-bottom: 10px;
	margin-top: 5px;
}

pre {

}

code {
	font-family: "Courier New", Courier, monospace;        
	font-size: 1em;
	border: 1px dashed #CDCDCD;
	background: #F2F2F2;
	padding: 1em;
	display: block;
}

ul, ol {
	margin-bottom:1.5em;
	padding-left:0;
}

ul {
	list-style-type:none;
	margin-left:0;
}	

ul li {
	padding-left: 1em;
	margin-bottom: 0.6em;
	background-position: left;
	background-repeat: no-repeat;
	vertical-align: top;
}

ul.bulletless li {
	padding-left: 0;
	background: none;
}

ol {
	list-style-type: decimal;
	margin-left: 2em;
}	

ol li {
	padding-left: 0;
	margin-bottom: 0.6em;
}

/*** Forms ***/

fieldset {
  margin-bottom: 1em;
}

label {
  font-weight: bold;
}

form.button-to div {
  display: inline;
}

fieldset.grid p {
  line-height: 1em;
  padding: 0.2em;
  margin: 0;
}

fieldset.grid label {
  display: block;
  float: left;
  min-width: 140px;
}


/*** Table Data ***/

table.data {
  width: 100%;
  border: 1px solid #333;
  margin-bottom: 0.5em;
  border-collapse: collapse;
}

table.data thead tr {
	background: #333;
	color: #dcdcdc;
	font-weight: bold;
}
table.data thead tr td {
  margin: 0;
}

table.data td {
	vertical-align: top;
	padding: 0.4em;
}

table.data tr.odd td {
	background: #ebf1f9;
	border-top: 1px solid #cad6e6;
	border-bottom: 1px solid #cad6e6;
}

table.data tr.unpublished-changes td {
  background: #FFC4C2;
  font-style: italic;
}

table.data tr.subtotal {
  background-color: #CCC;
  font-weight: bold;
}
table.data tr.subtotal td {
  border-top: 1px solid #333;
  border-bottom: 1px solid #333;
}


/** Tabs **/
.tabset {
	height: 26px; 
	border-bottom: 2px solid #004F96; 
	vertical-align: middle; 
	margin-bottom: 14px; 
	margin-top: 15px;
	font-size: 1em;
	font-weight: bold;
}

.tabset span {
	display: block;
	float: left;
	padding: 4px 12px;
}
.tabset span a:link { text-decoration: none; color: #004F96; }
.tabset span a:visited { text-decoration: none; color: #004F96; }
.tabset span a:hover { text-decoration: underline; color: #004F96; }

.tabset span.selected {
	padding: 4px 12px; 
	color: #FFFFFF;
	background-color: #004F96;
}
.tabset span.selected a:link { color: #FFFFFF; }
.tabset span.selected a:visited { color: #FFFFFF; }
.tabset span.selected a:hover { color: #FFFFFF; }



/** Pagination **/

.pagination {
  margin: 10px 0;
}

.pagination a, .pagination span {
  padding: .2em .5em;
  display: block;
  float: left;
  margin-right: 1px; 
}

.pagination span.disabled {
  color: #999;
  border: 1px solid #333; 
}

.pagination span.current {
  font-weight: bold;
  background: #0065B4;
  color: white;
  border: 1px solid #0065B4;
}

.pagination a {
  text-decoration: none;
  color: #0065B4;
  border: 1px solid #0065B4;
}
.pagination a:hover, .pagination a:focus {
  color: #0065B4;
  border-color: #0065B4;
}

.pagination .page_info {

}

.pagination .page_info b {

}

.pagination:after {
  content: ".";
  display: block;
  height: 0;
  clear: both;
  visibility: hidden;
}

* html .pagination {
  height: 1%; 
}

*:first-child+html .pagination {
  overflow: hidden; 
}
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
END

file "config/deploy/staging.rb", <<-END
role :app, "stage.#{application_domain}"
role :web, "stage.#{application_domain}"
role :db, "stage.#{application_domain}", :primary => true

set :rails_env, "staging"
set :branch, "master"
END

file "config/deploy/production.rb", <<-END
role :app, "#{application_domain}"
role :web, "#{application_domain}"
role :db, "#{application_domain}", :primary => true

set :rails_env, "production"
set :branch, "production"
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








