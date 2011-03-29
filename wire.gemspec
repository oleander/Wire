# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "wire"
  s.version     = "0.1.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Linus Oleander"]
  s.email       = ["linus@oleander.nu"]
  s.homepage    = "https://github.com/Oleander/Wire"
  s.summary     = %q{Run a strict amount of threads during a time interval}
  s.description = %q{Run a strict amount of threads during a time interval, primarily used for web scraping.}

  s.rubyforge_project = "wire"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.required_ruby_version = "~> 1.9.0"
  s.add_development_dependency("rspec", "~> 2.5.0")
end
