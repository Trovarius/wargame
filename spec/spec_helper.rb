ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
Bundler.require(:test)
require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.include AcceptanceExampleGroup, :example_group => { :file_path => /\bspec\/acceptance\// }
  config.include LoginHelper, :type => :acceptance
  config.mock_with :rspec
  config.fail_fast = true

  config.use_transactional_fixtures = true

end
