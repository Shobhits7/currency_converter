# lib/currency_converter.rb
require "net/http"
require "json"

module CurrencyConverter
  class Converter
    BASE_URL = "https://api.exchangerate-api.com/v4/latest/"

    def initialize(api_key)
      @api_key = api_key
    end

    def convert(amount, from_currency, to_currency)
      rate = fetch_exchange_rate(from_currency, to_currency)
      (amount * rate).round(2)
    end

    private

    def fetch_exchange_rate(from_currency, to_currency)
      url = "#{BASE_URL}#{from_currency}"
      response = Net::HTTP.get(URI(url))
      data = JSON.parse(response)

      if data && data["rates"] && data["rates"][to_currency]
        data["rates"][to_currency]
      else
        raise "Currency not supported or API error"
      end
    end
  end
end
