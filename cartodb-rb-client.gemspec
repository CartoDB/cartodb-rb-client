# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cartodb-rb-client/version"

Gem::Specification.new do |s|
  s.name        = "cartodb-rb-client"
  s.version     = Cartodb::Rb::Client::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Fernando Espinosa"]
  s.email       = ["fer@ferdev.com"]
  s.homepage    = %q{http://github.com/ferdev/cartodb-rb-client}
  s.licenses    = ["MIT"]
  s.summary     = %q{Ruby client for cartodb API}
  s.description = %q{Allows quick and easy connection to cartodb API.}

  s.rubyforge_project = "cartodb-rb-client"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_dependency 'typhoeus', '0.2.4'
  s.add_dependency 'json', '1.5.1'
  s.add_dependency 'omniauth',    '0.1.6'
  s.add_dependency 'warden',      '1.0.3'
  s.add_dependency 'mime-types',  '1.16'
  s.add_dependency 'rails_warden', '0.5.2'
  s.add_dependency 'activesupport', '3.0.5'
  s.add_dependency 'i18n', '0.5.0'
  s.add_dependency 'rgeo', '0.3.2'
  s.add_dependency 'rgeo-geojson', '0.2.0'
  s.add_dependency 'pg', '0.11.0'
end
