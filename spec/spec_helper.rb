require 'rubygems'
require 'bundler/setup'

require 'rb_exist'

# Ugly but effective...
$server_ip = 'localhost:8088'

# Load every single test
Dir[File.dirname(__FILE__) + '/*.rb'].each { |f| require f }
