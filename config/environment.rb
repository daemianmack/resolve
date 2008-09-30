# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.1.1' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use. To use Rails without a database
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Specify gems that this application depends on. 
  # They can then be installed with "rake gems:install" on new installations.
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "aws-s3", :lib => "aws/s3"

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Comment line to use default local time.
  config.time_zone = 'UTC'

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_resolve_session',
    :secret      => '29b1527ce955813b270e8b5cccff4573e97bb3ccb643df569630c218d78872bcd7e0a3490a7ac9cee314e4f3052a67fc8340512a931857a92e1def18d262533e'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with "rake db:sessions:create")
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
  # Customizable text strings - we probably want to put a lot of this into a YAML config file to facilitate customization.
  STATUS_FOR_NEW_TICKET = "New"
  STATUS_FOR_IN_PROGRESS_TICKET = "In Progress"
  STATUS_FOR_FINISHED_TICKET = "Finished"
  STATUS_FOR_CLOSED_TICKET = "Closed"
  DEFAULT_PAGE_TITLE = "ReSolve"

  # Brainstorm: here's how we can handle freeform role creation
  # Roles get assigned to users on a per-category basis
  # 
  # If a new constant is added here make sure you update Permission#all_possible_roles as well
  ROLES_WHICH_ALLOW_ITEM_CREATION = %w(requester watcher poster fixer)
  ROLES_WHICH_ALLOW_VIEWING_OF_ITEMS_FROM_OTHER_REQUESTERS = %w(watcher poster fixer)
  ROLES_WHICH_ALLOW_SETTING_AS_ITEM_WATCHER = %w(watcher poster fixer)
  ROLES_WHICH_ALLOW_POSTING_TO_ITEMS_FROM_OTHER_REQUESTERS = %w(poster fixer)
  ROLES_WHICH_ALLOW_ADDING_FILES_TO_ITEM = %w(poster fixer)
  ROLES_WHICH_ALLOW_CHANGING_ITEM_PRIORITY = %w(poster fixer)
  ROLES_WHICH_ALLOW_CHANGING_DUE_DATES_FOR_ITEMS_FROM_OTHER_REQUESTERS = %w(poster fixer)
  ROLES_WHICH_ALLOW_MOVING_TO_THIS_CATEGORY = %w(requester poster fixer)
  ROLES_WHICH_ALLOW_ASSIGNING_ITEM_FIXER = %w(fixer)
  ROLES_WHICH_ALLOW_SETTING_AS_ITEM_FIXER = %w(fixer)

  EVENT_ASSIGNED_ITEM_TO_FIXER = "%s assigned to %s"
  
  # Customizable features - as with strings, we probably want to put a lot of this into a YAML config file to facilitate customization.
  ITEM_FIELDS_WHICH_ALLOW_SORTING = %w(id priority dropdead_on created_at updated_at name)

  # Date customization. 
  ITEM_DASH_DATE_FORMAT = '%a %b %d, %I:%M%p' #Wed Sep 17, 07:44PM
end

Rails::Initializer.run do |config|
  config.gem 'mislav-will_paginate', :version => '~> 2.3.2', :lib => 'will_paginate',
    :source => 'http://gems.github.com'
end

require 'will_paginate' #necessary until rails' embedded version of this plugin contains the fix to preserve page params for custom routes

WillPaginate::ViewHelpers.pagination_options[:inner_window] = '1'
WillPaginate::ViewHelpers.pagination_options[:outer_window] = '0'
WillPaginate::ViewHelpers.pagination_options[:separator] = ''

require 'resolve_extensions'

# extend String with the TextHelper functions
class String #:nodoc:
  include ResolveExtensions::String::TextHelper
end

# Add sanitizing to all string & text model fields
ActiveRecord::Base.send(:include, ResolveExtensions::ActiveRecord::TextScrubber)
