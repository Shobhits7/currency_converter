# CurrencyConverter

CurrencyConverter is a Ruby gem for converting currencies based on real-time exchange rates.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'currency-converter', '~> 0.1.0'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install currency_converter

## Usage

To get your api key, you can sign up for free at [Exchange Rate API](https://www.exchangerate-api.com/)

```ruby
require "currency-converter"

converter = CurrencyConverter::Converter.new("your_api_key")
amount_in_eur = converter.convert(100, "USD", "EUR")
puts "Converted amount: #{amount_in_eur} EUR"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/shobhits7/currency_converter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/shobhits7/currency_converter/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the CurrencyConverter project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/shobhits7/currency_converter/blob/main/CODE_OF_CONDUCT.md).
