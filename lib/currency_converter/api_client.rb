# frozen_string_literal: true

require "net/http"
require "json"
require_relative "errors"

module CurrencyConverter
  # The APIClient class handles API requests to the external exchange rate provider.
  # Responsible for retrieving exchange rates based on the provided currencies.
  class APIClient
    BASE_URL = "https://api.exchangerate-api.com/v4/latest/"

    def initialize(api_key)
      @api_key = api_key
    end

    # Gets the exchange rate for a currency pair.
    # @param from_currency [String] the source currency code
    # @param to_currency [String] the target currency code
    # @return [Float] the exchange rate
    # @raise [RateNotFoundError, APIError] for invalid responses or network issues
    def get_rate(from_currency, to_currency)
      url = "#{BASE_URL}#{from_currency}"
      response = Net::HTTP.get(URI(url))
      data = JSON.parse(response)

      data.dig("rates", to_currency) || raise(RateNotFoundError, "#{to_currency} rate not available")
    rescue JSON::ParserError
      raise APIError, "Invalid API response format"
    rescue Net::HTTPError, SocketError => e
      raise APIError, "Network error: #{e.message}"
    end
  end
end
