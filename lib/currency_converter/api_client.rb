# frozen_string_literal: true

require "net/http"
require "json"
require_relative "errors"

module CurrencyConverter
  # The APIClient class handles API requests to the external exchange rate provider.
  # Responsible for retrieving exchange rates based on the provided currencies.
  # Supports both v6 authenticated (with API key) and v6 open access (without API key) endpoints.
  class APIClient
    # v6 authenticated endpoint (requires API key, better rate limits)
    AUTHENTICATED_BASE_URL = "https://v6.exchangerate-api.com/v6"

    # v6 open access endpoint (no API key required, lower rate limits)
    OPEN_ACCESS_BASE_URL = "https://open.er-api.com/v6/latest"

    def initialize(api_key, timeout: CurrencyConverter.configuration&.timeout || 10)
      @api_key = api_key
      @timeout = timeout
      @use_authenticated = !api_key.nil? && !api_key.empty?

      log_api_mode if CurrencyConverter.configuration&.logger
    end

    # Gets the exchange rate for a currency pair.
    # @param from_currency [String] the source currency code
    # @param to_currency [String] the target currency code
    # @return [Float] the exchange rate
    # @raise [RateNotFoundError, APIError, TimeoutError] for invalid responses, network issues, or timeout
    def get_rate(from_currency, to_currency)
      url = build_url(from_currency)
      uri = URI(url)

      response = fetch_with_timeout(uri)
      data = JSON.parse(response)

      # Check for API-specific errors in v6 response
      handle_v6_errors(data)

      # Extract rate from v6 response format
      rate = data.dig("conversion_rates", to_currency) || data.dig("rates", to_currency)
      raise(RateNotFoundError, "#{to_currency} rate not available") unless rate

      rate
    rescue JSON::ParserError
      raise APIError, "Invalid API response format"
    rescue Timeout::Error, Net::OpenTimeout, Net::ReadTimeout => e
      raise TimeoutError, "Request timed out after #{@timeout} seconds: #{e.message}"
    rescue Net::HTTPError, SocketError => e
      raise APIError, "Network error: #{e.message}"
    end

    private

    # Builds the appropriate URL based on authentication mode
    # @param from_currency [String] the base currency code
    # @return [String] the complete API URL
    def build_url(from_currency)
      if @use_authenticated
        "#{AUTHENTICATED_BASE_URL}/#{@api_key}/latest/#{from_currency}"
      else
        "#{OPEN_ACCESS_BASE_URL}/#{from_currency}"
      end
    end

    # Handles v6-specific error responses
    # @param data [Hash] the parsed JSON response
    # @raise [APIError] for various v6 API errors
    def handle_v6_errors(data)
      return unless data["result"] == "error"

      error_type = data["error-type"]
      case error_type
      when "invalid-key"
        raise APIError, "Invalid API key provided"
      when "inactive-account"
        raise APIError, "API account is inactive"
      when "quota-reached"
        raise APIError, "API rate limit quota reached"
      when "unsupported-code"
        raise APIError, "Unsupported currency code"
      else
        raise APIError, "API error: #{error_type || 'unknown error'}"
      end
    end

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

    # Logs the API mode being used
    def log_api_mode
      if @use_authenticated
        CurrencyConverter.configuration.logger.info(
          "CurrencyConverter: Using v6 authenticated API (better rate limits)"
        )
      else
        CurrencyConverter.configuration.logger.info(
          "CurrencyConverter: Using v6 open access API (free tier). " \
          "Configure an API key for better rate limits: https://www.exchangerate-api.com"
        )
      end
    end
  end
end
