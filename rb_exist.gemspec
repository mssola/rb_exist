# coding: UTF-8

$: << File.expand_path(File.dirname(__FILE__))
require 'lib/rb_exist.rb'


Gem::Specification.new do |s|
  s.name                = Exist::NAME
  s.version             = Exist::VERSION
  s.platform            = Gem::Platform::RUBY
  s.authors             = ['Miquel Sabaté']
  s.email               = ['mikisabate@gmail.com']
  s.homepage            = 'http://github.com/mssola/rb_exist'
  s.summary             = Exist::SUMMARY
  s.description         = Exist::DESCRIPTION
  s.license             = Exist::LICENSE
  s.files               = `git ls-files`.split("\n")
  s.require_path        = 'lib'

  s.required_rubygems_version = ">= 1.3.6"
  s.required_ruby_version     = ">= 1.9"
end
