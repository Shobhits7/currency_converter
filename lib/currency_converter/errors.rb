# frozen_string_literal: true

module CurrencyConverter
  # Custom error class for API-related errors.
  class APIError < StandardError; end

  # Custom error class for cases where a specific exchange rate is not found.
  class RateNotFoundError < StandardError; end

  # Custom error class for invalid amount inputs.
  class InvalidAmountError < StandardError; end

  # Custom error class for invalid currency code inputs.
  class InvalidCurrencyError < StandardError; end

  # Custom error class for timeout errors.
  class TimeoutError < StandardError; end
end
