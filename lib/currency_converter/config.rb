# frozen_string_literal: true

# Configuration module for the CurrencyConverter gem.
# Holds settings for API key, cache duration, and logger.
# The Configuration class allows users to set these globally for the gem.
module CurrencyConverter
  # The Configuration class defines settings that can be adjusted
  # for the CurrencyConverter gem, such as:
  # - `api_key`: The API key required for accessing the currency exchange service.
  # - `cache_duration`: Duration for which the exchange rates should be cached.
  # - `logger`: Configurable logger for logging any errors or information.
  class Configuration
    attr_accessor :api_key, :cache_duration, :logger

    def initialize
      @api_key = ENV["CURRENCY_CONVERTER_API_KEY"]
      @cache_duration = 1.hour # Default cache duration is 1 hour
      @logger = Logger.new($stdout)
    end
  end

  class << self
    attr_accessor :configuration

    # Yields a configuration block to set global settings for the gem.
    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end
  end
end
