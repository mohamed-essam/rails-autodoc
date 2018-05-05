
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "autodoc/version"

Gem::Specification.new do |spec|
  spec.name          = "autodoc"
  spec.version       = Autodoc::VERSION
  spec.authors       = ["Mohamed Essam Arafa"]
  spec.email         = ["mohamed.essam.arafa@gmail.com"]

  spec.summary       = %q{Automatically generate Swagger yaml documentation files for a rails project using a middleware}
  spec.homepage      = "https://github.com/mohamed-essam/rails-autodoc"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'rack'
  spec.add_dependency 'activesupport'

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
