# frozen_string_literal: true

# Main module for the CurrencyConverter gem.
# Provides methods for currency conversion with caching and error handling.
require "net/http"
require "json"
require "logger"
require "active_support/cache"
require_relative "config"
require_relative "api_client"
require_relative "cache"

module CurrencyConverter
  # The Converter class performs currency conversions using exchange rates.
  # It retrieves rates from an external API and caches them for performance.
  class Converter
    def initialize(api_key: CurrencyConverter.configuration.api_key)
      # Initializes the API client with the provided or configured API key.
      # Initializes a caching object for exchange rates.
      @api_client = APIClient.new(api_key)
      @cache = Cache.new
    end

    # Converts a given amount from one currency to another.
    # @param amount [Float] the amount of currency to convert
    # @param from_currency [String] the source currency code (e.g., "USD")
    # @param to_currency [String] the target currency code (e.g., "EUR")
    # @return [Float] the converted amount
    # @raise [CurrencyConverter::APIError] if conversion fails due to API or network errors
    def convert(amount, from_currency, to_currency)
      rate = fetch_exchange_rate(from_currency, to_currency)
      (amount * rate).round(2)
    rescue CurrencyConverter::RateNotFoundError => e
      log_error("Conversion failed: #{e.message}")
      raise CurrencyConverter::APIError, "Conversion failed: #{e.message}"
    rescue StandardError => e
      log_error("Conversion failed: #{e.message}")
      raise
    end

    private

    # Fetches the exchange rate, using the cache if available.
    # If the rate is not in the cache, retrieves it from the API.
    # @param from_currency [String] the source currency code
    # @param to_currency [String] the target currency code
    # @return [Float] the exchange rate
    def fetch_exchange_rate(from_currency, to_currency)
      @cache.fetch("#{from_currency}_#{to_currency}") do
        @api_client.get_rate(from_currency, to_currency)
      end
    end

    # Logs errors to the configured logger for easier debugging.
    # @param message [String] the error message to log
    def log_error(message)
      CurrencyConverter.configuration.logger.error(message)
    end
  end
end
