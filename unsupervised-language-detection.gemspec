# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "unsupervised-language-detection/version"

Gem::Specification.new do |s|
  s.name        = "unsupervised-language-detection"
  s.version     = UnsupervisedLanguageDetection::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Edwin Chen"]
  s.email       = ["hello@echen.me"]
  s.homepage    = ""
  s.summary     = %q{Perform unsupervised language detection.}
  s.description = %q{Perform unsupervised language detection, specifically for the purpose of finding English-language tweets.}

  s.rubyforge_project = "unsupervised-language-detection"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end