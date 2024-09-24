# frozen_string_literal: true

require_relative "lib/skap/version"

Gem::Specification.new do |spec|
  spec.name = "skap"
  spec.version = Skap::VERSION
  spec.summary = ""
  # spec.description = ""
  spec.authors = ["Evgeniy Nochevnov"]
  spec.homepage = "https://github.com/crosspath/skap"
  spec.license = "MIT"

  spec.required_ruby_version = Gem::Requirement.new(">= 3.3.0")

  spec.add_development_dependency("rspec-core", "~> 3.13")
  spec.add_development_dependency("rspec-expectations", "~> 3.13")
  spec.add_development_dependency("rubocop", "~> 1.66")
  spec.add_development_dependency("rubocop-performance", "~> 1.22")
  spec.add_development_dependency("yard", "~> 0.9")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files =
    Dir.chdir(File.expand_path(__dir__)) do
      `git ls-files -z`.split("\x0").grep_v(%r{^spec/})
    end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
