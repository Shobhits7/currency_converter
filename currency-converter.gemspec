# frozen_string_literal: true

require_relative "lib/currency_converter/version"

Gem::Specification.new do |spec|
  spec.name = "currency-converter"
  spec.version = CurrencyConverter::VERSION
  spec.authors = ["Shobhit Jain"]
  spec.email = ["shobjain09@gmail.com"]

  spec.summary       = "A simple gem for currency conversion."
  spec.description   = "Fetches real-time currency exchange rates and allows currency conversion."
  spec.homepage      = "https://github.com/shobhits7/currency_converter"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/shobhits7/currency_converter"
  # spec.metadata["changelog_uri"] = "https://github.com/shobhits7/currency_converter"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
