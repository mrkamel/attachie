# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'attachie/version'

Gem::Specification.new do |spec|
  spec.name          = "attachie"
  spec.version       = Attachie::VERSION
  spec.authors       = ["Benjamin Vetter"]
  spec.email         = ["vetter@plainpicture.de"]
  spec.summary       = %q{Declarative and flexible attachments}
  spec.description   = %q{Declarative and flexible attachments}
  spec.homepage      = "https://github.com/mrkamel/attachie"
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/mrkamel/attache"
  spec.metadata["changelog_uri"] = "https://github.com/mrkamel/attache/blob/master/CHANGELOG.md"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-sdk-s3"
  spec.add_dependency "mime-types"
  spec.add_dependency "connection_pool"
  spec.add_dependency "activesupport"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "fakes3"
  spec.add_development_dependency "timecop"
end
