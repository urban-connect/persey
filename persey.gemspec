# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "persey"
  spec.version = "2.0.0"
  spec.authors = ["Urban Connect"]
  spec.summary = "Simple configuration DSL with environment inheritance"

  spec.required_ruby_version = ">= 3.0"

  spec.files = Dir["lib/**/*.rb"]
  spec.require_paths = ["lib"]
end
