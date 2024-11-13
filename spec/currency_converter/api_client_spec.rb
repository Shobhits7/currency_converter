# frozen_string_literal: true

require "currency_converter"
require "webmock/rspec"

RSpec.describe CurrencyConverter::APIClient do
  let(:client) { described_class.new("test_key") }

  describe "#get_rate" do
    it "returns the exchange rate for a valid currency pair" do
      stub_request(:get, "https://api.exchangerate-api.com/v4/latest/USD")
        .to_return(body: { rates: { "EUR" => 0.85 } }.to_json)

      expect(client.get_rate("USD", "EUR")).to eq(0.85)
    end

    it "raises a RateNotFoundError if the rate is missing" do
      stub_request(:get, "https://api.exchangerate-api.com/v4/latest/USD")
        .to_return(body: { rates: {} }.to_json)

      expect { client.get_rate("USD", "EUR") }.to raise_error(CurrencyConverter::RateNotFoundError)
    end
  end
end
