# coding: UTF-8


Gem::Specification.new do |s|
  s.name                = 'rb_exist'
  s.version             = '0.0.1'
  s.platform            = Gem::Platform::RUBY
  s.authors             = ['Miquel Sabaté']
  s.email               = ['mikisabate@gmail.com']
  s.homepage            = 'http://github.com/mssola/rb_exist'
  s.summary             = 'Ruby support for eXist-db'
  s.description         = 'A gem that gives support to the eXist-db.'
  s.license             = 'LGPLv3+'
  s.files               = `git ls-files`.split("\n")
  s.require_path        = 'lib'

  s.required_rubygems_version = ">= 1.3.6"
  s.required_ruby_version     = ">= 1.9"
end
