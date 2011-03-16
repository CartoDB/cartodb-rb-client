$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'yaml'
require 'cartodb-rb-client'
require 'cartodb-rb-client/cartodb'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.before(:all) do
    CartoDB::Settings = YAML.load_file("#{File.dirname(__FILE__)}/support/cartodb_config.yml")

    @cartodb = CartoDB::Client.new
  end

  config.before(:each) do
    drop_all_cartodb_tables @cartodb
  end

  config.after(:all) do
    drop_all_cartodb_tables @cartodb
  end
end
