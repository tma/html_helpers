# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "html_helpers"
  s.version     = '1.1.3'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ruben Nine", "Thomas Maurer"]
  s.email       = ["tma@freshbit.ch"]
  s.homepage    = "https://github.com/tma/html_helpers"
  s.summary     = %q{Rails Plugin with Helpers to en- and decode HTML Entities}
  s.description = %q{Encode and decode HTML entities in your views and other classes}
  s.license     = 'MIT'
  
  s.rubyforge_project = "html_helpers"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end