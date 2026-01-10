# CurrencyConverter

[![Gem Version](https://badge.fury.io/rb/currency-converter.svg?icon=si%3Arubygems)](https://badge.fury.io/rb/currency-converter)
[![Downloads](https://img.shields.io/gem/dt/currency-converter.svg)](https://rubygems.org/gems/currency-converter)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

The CurrencyConverter gem provides an easy way to perform currency conversions. It allows you to convert amounts between different currencies using real-time exchange rates from ExchangeRate-API, while offering caching for performance improvements and comprehensive error handling for robustness.

**Version 1.2.0** brings significant improvements including v6 API support, input validation, HTTP timeout protection, and 100% test coverage.

Author: Developed by [Shobhit Jain](https://github.com/shobhits7).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'currency-converter', '~> 1.2.0'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install currency-converter

## Configuration

The gem can be used with or without configuration. For better rate limits and performance, it's recommended to configure it with an API key.

### Basic Usage (No Configuration Required)

The gem works out of the box using the v6 open access API:

```ruby
converter = CurrencyConverter::Converter.new
amount_in_eur = converter.convert(100, 'USD', 'EUR')
```

### Advanced Configuration (Recommended)

To get your free API key, sign up at [Exchange Rate API](https://www.exchangerate-api.com/)

```ruby
CurrencyConverter.configure do |config|
  config.api_key = 'your_api_key_here'     # Optional: For better rate limits (v6 authenticated API)
  config.cache_duration = 3600             # Optional: Cache duration in seconds (default: 1 hour)
  config.timeout = 10                      # Optional: HTTP timeout in seconds (default: 10)
  config.logger = Logger.new(STDOUT)       # Optional: Configure logging
end
```

**Configuration Options:**

- **api_key** (Optional): Your API key for v6 authenticated access with higher rate limits. Without it, the gem uses the v6 open access API (free tier).
- **cache_duration** (Optional): Duration in seconds for caching exchange rates. Default: 3600 seconds (1 hour).
- **timeout** (Optional): HTTP request timeout in seconds. Prevents hanging on slow connections. Default: 10 seconds.
- **logger** (Optional): Logger instance for debugging and monitoring. Default: Logger writing to STDOUT.


## Usage

### Creating an Instance of the Converter

Create an instance of the `CurrencyConverter::Converter` class to perform currency conversions:

```ruby
converter = CurrencyConverter::Converter.new
```

### Converting Currency

Use the `convert` method to convert an amount from one currency to another:

```ruby
# Convert 100 USD to EUR
amount_in_eur = converter.convert(100, 'USD', 'EUR')
puts amount_in_eur  # => 85.0 (example rate)

# Convert with decimal amounts
amount_in_gbp = converter.convert(99.99, 'USD', 'GBP')
puts amount_in_gbp  # => 75.99 (example rate)
```

**Parameters:**

- **amount** (Numeric): The amount to convert. Must be a positive number (Integer or Float).
- **from_currency** (String): Source currency code in ISO 4217 format (3 uppercase letters, e.g., "USD").
- **to_currency** (String): Target currency code in ISO 4217 format (3 uppercase letters, e.g., "EUR").

**Returns:** The converted amount as a Float, rounded to 2 decimal places.

### Input Validation

Version 1.2.0 includes comprehensive input validation:

```ruby
# Valid inputs
converter.convert(100, 'USD', 'EUR')     # ✓ Valid
converter.convert(0, 'USD', 'EUR')       # ✓ Valid (zero is allowed)
converter.convert(99.99, 'USD', 'GBP')   # ✓ Valid (decimals allowed)

# Invalid inputs that will raise errors
converter.convert(nil, 'USD', 'EUR')     # ✗ Raises InvalidAmountError
converter.convert(-100, 'USD', 'EUR')    # ✗ Raises InvalidAmountError
converter.convert('100', 'USD', 'EUR')   # ✗ Raises InvalidAmountError
converter.convert(100, 'usd', 'EUR')     # ✗ Raises InvalidCurrencyError (must be uppercase)
converter.convert(100, 'US', 'EUR')      # ✗ Raises InvalidCurrencyError (must be 3 letters)
converter.convert(100, nil, 'EUR')       # ✗ Raises InvalidCurrencyError
```

## Error Handling

Version 1.2.0 provides comprehensive error handling with specific exception types:

### Exception Types

- **`InvalidAmountError`**: Raised when the amount is invalid (nil, negative, or non-numeric)
- **`InvalidCurrencyError`**: Raised when currency codes are invalid (nil, wrong format, not ISO 4217)
- **`TimeoutError`**: Raised when the API request times out
- **`APIError`**: Raised for API-related failures (network errors, missing rates, API quota reached)
- **`RateNotFoundError`**: Raised when a specific currency rate is not available from the API

### Error Handling Examples

```ruby
begin
  amount_in_eur = converter.convert(100, 'USD', 'EUR')
  puts "Converted amount: #{amount_in_eur} EUR"
rescue CurrencyConverter::InvalidAmountError => e
  puts "Invalid amount: #{e.message}"
rescue CurrencyConverter::InvalidCurrencyError => e
  puts "Invalid currency: #{e.message}"
rescue CurrencyConverter::TimeoutError => e
  puts "Request timed out: #{e.message}"
rescue CurrencyConverter::APIError => e
  puts "API error: #{e.message}"
rescue StandardError => e
  puts "Unexpected error: #{e.message}"
end
```

### Common Error Messages

```ruby
# Invalid amount errors
"Amount cannot be nil"
"Amount must be a number"
"Amount cannot be negative"

# Invalid currency errors
"from_currency cannot be nil"
"from_currency must be a 3-letter uppercase code (e.g., 'USD')"
"to_currency must be a 3-letter uppercase code (e.g., 'EUR')"

# API errors
"Request timed out after 10 seconds"
"Invalid API key provided"
"API rate limit quota reached"
"Unsupported currency code: XYZ"
"EUR rate not available"
```

## Testing

The gem has **100% test coverage** with comprehensive test suites covering all functionality.

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run with coverage report
bundle exec rspec
# View coverage report: open coverage/index.html

# Run code quality checks
bundle exec rubocop

# Run manual integration tests (with real API)
ruby manual_integration_test.rb
```

### Test Coverage

**Version 1.2.0 Test Statistics:**
- **43 test examples**, 0 failures
- **100% code coverage** (125/125 lines)
- **0 RuboCop offenses**
- All tests use WebMock to stub external API calls for consistency
- Manual integration test script included for real API verification

### Example Test

```ruby
RSpec.describe CurrencyConverter::Converter do
  let(:converter) { CurrencyConverter::Converter.new }

  it 'performs currency conversion successfully' do
    # WebMock stubs the API call
    allow_any_instance_of(CurrencyConverter::APIClient)
      .to receive(:get_rate)
      .and_return(0.85)

    result = converter.convert(100, 'USD', 'EUR')
    expect(result).to eq(85.0)
  end

  it 'raises InvalidAmountError for negative amounts' do
    expect { converter.convert(-100, 'USD', 'EUR') }
      .to raise_error(CurrencyConverter::InvalidAmountError)
  end

  it 'raises InvalidCurrencyError for invalid currency codes' do
    expect { converter.convert(100, 'usd', 'EUR') }
      .to raise_error(CurrencyConverter::InvalidCurrencyError)
  end
end
```

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for detailed version history and release notes.

**Latest Release (v1.2.0 - 2026-01-10):**
- Migrated to ExchangeRate-API v6 with dual-mode support
- Added comprehensive input validation
- Fixed cache duration implementation
- Added HTTP timeout configuration
- Achieved 100% test coverage
- Zero code quality issues

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
