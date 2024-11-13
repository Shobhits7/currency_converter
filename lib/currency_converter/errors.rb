# frozen_string_literal: true

module CurrencyConverter
  # Custom error class for API-related errors.
  class APIError < StandardError; end

  # Custom error class for cases where a specific exchange rate is not found.
  class RateNotFoundError < StandardError; end
end
