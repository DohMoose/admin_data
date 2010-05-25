pwd = File.dirname(__FILE__)

$:.unshift File.join(pwd + '..', 'lib')
$:.unshift File.join(pwd + '..', 'app')
$:.unshift File.join(pwd + '..', 'app', 'controllers')
$:.unshift File.join(pwd + '..', 'app', 'controllers', 'admin_data')

module AdminData
end

ENV['RAILS_ENV'] = 'test'

rails_root = File.join(pwd , 'rails_root')

# start rails
require "#{rails_root}/config/environment.rb"

#require all the lib files plugin needs
Dir[File.join(pwd, '..', 'lib', 'admin_data', '*.rb')].each {|f| require f}

#require validation code
f = File.join(pwd, '..', 'lib', '*.rb')
Dir.glob(f).each {|file| require file }

AdminDataConfig.initialize_defaults

#require all the controllers plugins needs
Dir[File.join(pwd, '..', 'app', 'controllers', 'admin_data', '*.rb')].each {|f| require f}

# make sure that plugin views have access to helpers
ActionView::Base.send :include, AdminData::Helpers

#require plugin routes
require "#{rails_root}/../../config/routes.rb"

#require all the controllers from the test controllers
f = File.join(pwd, 'rails_root', 'app', 'controllers', '*.rb')
Dir.glob(f).each {|controller| require controller }

require 'test/unit'
require 'test_help'
silence_warnings { RAILS_ENV = ENV['RAILS_ENV'] }

# Run the migrations
ActiveRecord::Migration.verbose = false
ActiveRecord::Migrator.migrate("#{rails_root}/db/migrate")


gem 'shoulda','>= 2.10.2'
require 'shoulda'

gem 'will_paginate'
require 'will_paginate'

gem 'factory_girl', '= 1.2.4'
require 'factory_girl'

gem 'flexmock'
require 'flexmock'

gem 'redgreen'
require 'RedGreen'

# to test helper tests
require 'action_view/test_case'

Dir[File.join(pwd, 'factories', '*.rb')].each { |f| require File.expand_path(f) }

class ActiveSupport::TestCase

  def revoke_read_only_access
    AdminDataConfig.set = ({:is_allowed_to_view => Proc.new { |controller| false } })
  end

  def grant_read_only_access
    AdminDataConfig.set = ({:is_allowed_to_view => Proc.new { |controller| true } })
  end

  def grant_update_access
    AdminDataConfig.set = ({:is_allowed_to_update => Proc.new { |controller| true } })
  end

  def revoke_update_access
    AdminDataConfig.set = ({:is_allowed_to_update => Proc.new { |controller| false } })
  end

  def show_response
    Dir.mkdir(File.join(RAILS_ROOT, 'tmp')) unless File.directory?(File.join(RAILS_ROOT,'tmp'))
    response_html = File.join(RAILS_ROOT, 'tmp', 'response.html')
    File.open(response_html, 'w') { |f| f.write(@response.body) }
    system 'open ' + File.expand_path(response_html) rescue nil
  end

end

