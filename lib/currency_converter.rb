# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module CurrencyConverter
  # Converter class for currency conversion using an external API
  class Converter
    BASE_URL = "https://api.exchangerate-api.com/v4/latest/"

    # Initialize with an optional API key, if the API requires it
    # @param [String] api_key - optional API key for authentication
    def initialize(api_key = nil)
      @api_key = api_key
    end

    # Converts a given amount from one currency to another
    # @param [Float] amount - The amount of currency to convert
    # @param [String] from_currency - The currency code to convert from (e.g., 'USD')
    # @param [String] to_currency - The currency code to convert to (e.g., 'EUR')
    # @return [Float] - Converted amount rounded to two decimal places
    def convert(amount, from_currency, to_currency)
      rate = fetch_exchange_rate(from_currency, to_currency)
      (amount * rate).round(2)
    end

    private

    # Fetches the exchange rate between two currencies
    # @param [String] from_currency - The currency code to convert from
    # @param [String] to_currency - The currency code to convert to
    # @return [Float] - The exchange rate from `from_currency` to `to_currency`
    # @raise [StandardError] - If the currency is not supported or API request fails
    def fetch_exchange_rate(from_currency, to_currency)
      data = fetch_data(from_currency)
      parse_exchange_rate(data, to_currency)
    end

    # Constructs and performs the API request
    # @param [String] from_currency - The currency code to convert from
    # @return [Hash] - Parsed JSON response data
    # @raise [StandardError] - If JSON parsing or request fails
    def fetch_data(from_currency)
      url = URI("#{BASE_URL}#{from_currency}")
      response = Net::HTTP.get(url)
      JSON.parse(response)
    rescue JSON::ParserError
      raise StandardError, "Failed to parse response from API"
    end

    # Parses and retrieves the exchange rate from the API data
    # @param [Hash] data - Parsed JSON data from the API
    # @param [String] to_currency - The target currency code
    # @return [Float] - The exchange rate for the target currency
    # @raise [StandardError] - If the currency is not supported
    def parse_exchange_rate(data, to_currency)
      raise StandardError, "Currency not supported or API error" unless data["rates"] && data["rates"][to_currency]

      data["rates"][to_currency]
    end
  end
end
