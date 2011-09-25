require 'rubygems'
require 'bundler/setup'

require 'rb_exist'

# Load every single test
Dir['spec/*.rb'].each { |f| require f }

