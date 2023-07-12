# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-parser-winevt_xml"
  spec.version       = "0.2.6"
  spec.authors       = ["Hiroshi Hatake", "Masahiro Nakagawa"]
  spec.email         = ["cosmo0920.oucc@gmail.com", "repeatedly@gmail.com"]
  spec.summary       = %q{Fluentd Parser plugin to parse XML rendered windows event log.}
  spec.description   = %q{Fluentd Parser plugin to parse XML rendered windows event log.}
  spec.homepage      = "https://github.com/fluent/fluent-plugin-parser-winevt_xml"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "test-unit", "~> 3.4.0"
  spec.add_runtime_dependency "fluentd", [">= 0.14.12", "< 2"]
  spec.add_runtime_dependency "nokogiri", [">= 1.12.5", "< 1.16"]
end
