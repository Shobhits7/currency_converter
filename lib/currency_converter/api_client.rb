# frozen_string_literal: true

require "net/http"
require "json"
require_relative "errors"

module CurrencyConverter
  # The APIClient class handles API requests to the external exchange rate provider.
  # Responsible for retrieving exchange rates based on the provided currencies.
  class APIClient
    BASE_URL = "https://api.exchangerate-api.com/v4/latest/"

    def initialize(api_key, timeout: CurrencyConverter.configuration&.timeout || 10)
      @api_key = api_key
      @timeout = timeout
    end

    # Gets the exchange rate for a currency pair.
    # @param from_currency [String] the source currency code
    # @param to_currency [String] the target currency code
    # @return [Float] the exchange rate
    # @raise [RateNotFoundError, APIError, TimeoutError] for invalid responses, network issues, or timeout
    def get_rate(from_currency, to_currency)
      url = "#{BASE_URL}#{from_currency}"
      uri = URI(url)

      response = fetch_with_timeout(uri)
      data = JSON.parse(response)

      data.dig("rates", to_currency) || raise(RateNotFoundError, "#{to_currency} rate not available")
    rescue JSON::ParserError
      raise APIError, "Invalid API response format"
    rescue Timeout::Error, Net::OpenTimeout, Net::ReadTimeout => e
      raise TimeoutError, "Request timed out after #{@timeout} seconds: #{e.message}"
    rescue Net::HTTPError, SocketError => e
      raise APIError, "Network error: #{e.message}"
    end

    private

    # Fetches data from the URI with timeout configuration
    # @param uri [URI] the URI to fetch from
    # @return [String] the response body
    def fetch_with_timeout(uri)
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
                      open_timeout: @timeout, read_timeout: @timeout) do |http|
        request = Net::HTTP::Get.new(uri)
        response = http.request(request)
        response.body
      end
    end
  end
end
