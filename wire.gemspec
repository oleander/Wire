# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "wire/version"

Gem::Specification.new do |s|
  s.name        = "wire"
  s.version     = Wire::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Linus Oleander"]
  s.email       = ["linus@oleander.nu"]
  s.homepage    = "https://github.com/Oleander/wire"
  s.summary     = %q{Run your threads within a time interval}
  s.description = %q{Run your threads within a time interval, using Ruby}

  s.rubyforge_project = "wire"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.required_ruby_version = "~> 1.9.0"
end
