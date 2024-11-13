# CurrencyConverter

The CurrencyConverter gem provides an easy way to perform currency conversions. It allows you to convert amounts between different currencies using real-time exchange rates from an external API, while offering caching for performance improvements and error handling for robustness.

Author
Developed by [Shobhit Jain](https://github.com/shobhits7).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'currency-converter', '~> 0.1.0'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install currency-converter

## Configuration

Before using the gem, you need to configure it by setting up the necessary API key and cache duration. The gem uses an external API for exchange rates, so you'll need an API key for that.

Setting up Configuration
To get your api key, you can sign up for free at [Exchange Rate API](https://www.exchangerate-api.com/)

```ruby
CurrencyConverter.configure do |config|
  config.api_key = 'your_api_key_here'     # Your API key for the external API
  config.cache_duration = 60               # Cache duration in seconds
  config.logger = Logger.new(STDOUT)       # Optional: Configure logging
end
```

> api_key: Your API key for accessing exchange rates from the external provider.

> cache_duration: The duration for which exchange rates should be cached (in seconds).

> logger: Optional logging configuration for debugging purposes.


## Usage
Creating an Instance of the Converter
You can create an instance of the `CurrencyConverter::Converter` class to perform currency conversions.

```ruby
# Initialize the converter with the configured API key
converter = CurrencyConverter::Converter.new
```

### Converting Currency

Use the convert method to convert an amount from one currency to another.

```ruby
# Convert 100 USD to EUR
amount_in_eur = converter.convert(100, 'USD', 'EUR')
puts amount_in_eur
```

> amount: The amount you want to convert.

> from_currency: The source currency code (e.g., "USD").

> to_currency: The target currency code (e.g., "EUR").

This method will return the converted amount as a Float and will raise an error if the conversion fails (e.g., if the exchange rate for the requested currency pair is unavailable).

## Handling Errors
The convert method raises errors in the following situations:

> Missing Rate: If the exchange rate for the requested currency pair is not available, a CurrencyConverter::APIError is raised.

> General Conversion Failure: If any other issues occur (e.g., network failure), a StandardError is raised.

## Example of Handling Errors:

```ruby
begin
  amount_in_eur = converter.convert(100, 'USD', 'EUR')
  puts "Converted amount: #{amount_in_eur} EUR"
rescue CurrencyConverter::APIError => e
  puts "Conversion failed: #{e.message}"
rescue StandardError => e
  puts "An unexpected error occurred: #{e.message}"
end
```

## Testing

The gem is tested with RSpec, and several tests are included for verifying the correctness of functionality such as caching, conversion, and error handling.

Example Test:
```ruby
RSpec.describe CurrencyConverter::Converter do
  let(:converter) { CurrencyConverter::Converter.new }

  it 'performs currency conversion successfully' do
    result = converter.convert(100, 'USD', 'EUR')
    expect(result).to be_a(Float)
  end

  it 'raises an error if the conversion fails' do
    expect { converter.convert(100, 'USD', 'XYZ') }.to raise_error(CurrencyConverter::APIError)
  end
end
```

## Test Setup:
Ensure you have the required API key and any necessary configuration before running the tests. Mocking external API calls in tests is recommended for consistent results.

## Changelog
> v1.0.0

Initial release with currency conversion and caching support.
Error handling for missing rates and failed conversions.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

If you'd like to contribute to the development of this gem, feel free to fork the repository and create a pull request with your changes. Ensure that you write tests for any new features or bug fixes, and follow the style guide for Ruby code and RSpec testing.

Bug reports and pull requests are welcome on GitHub at https://github.com/shobhits7/currency_converter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/shobhits7/currency_converter/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the CurrencyConverter project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/shobhits7/currency_converter/blob/main/CODE_OF_CONDUCT.md).
