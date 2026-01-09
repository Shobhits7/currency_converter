# frozen_string_literal: true

require "currency_converter"
require "webmock/rspec"

RSpec.describe CurrencyConverter::APIClient do
  let(:client) { described_class.new("test_key", timeout: 5) }

  describe "#get_rate" do
    context "with successful requests" do
      it "returns the exchange rate for a valid currency pair" do
        stub_request(:get, "https://api.exchangerate-api.com/v4/latest/USD")
          .to_return(body: { rates: { "EUR" => 0.85 } }.to_json)

        expect(client.get_rate("USD", "EUR")).to eq(0.85)
      end

      it "uses custom timeout configuration" do
        custom_client = described_class.new("test_key", timeout: 15)
        stub_request(:get, "https://api.exchangerate-api.com/v4/latest/USD")
          .to_return(body: { rates: { "EUR" => 0.85 } }.to_json)

        expect(custom_client.get_rate("USD", "EUR")).to eq(0.85)
      end
    end

    context "with error scenarios" do
      it "raises a RateNotFoundError if the rate is missing" do
        stub_request(:get, "https://api.exchangerate-api.com/v4/latest/USD")
          .to_return(body: { rates: {} }.to_json)

        expect { client.get_rate("USD", "EUR") }
          .to raise_error(CurrencyConverter::RateNotFoundError, /EUR rate not available/)
      end

      it "raises an APIError for invalid JSON response" do
        stub_request(:get, "https://api.exchangerate-api.com/v4/latest/USD")
          .to_return(body: "invalid json")

        expect { client.get_rate("USD", "EUR") }
          .to raise_error(CurrencyConverter::APIError, /Invalid API response format/)
      end

      it "raises a TimeoutError when request times out" do
        stub_request(:get, "https://api.exchangerate-api.com/v4/latest/USD")
          .to_timeout

        expect { client.get_rate("USD", "EUR") }
          .to raise_error(CurrencyConverter::TimeoutError, /Request timed out/)
      end

      it "raises an APIError for network errors" do
        stub_request(:get, "https://api.exchangerate-api.com/v4/latest/USD")
          .to_raise(SocketError.new("Failed to open TCP connection"))

        expect { client.get_rate("USD", "EUR") }
          .to raise_error(CurrencyConverter::APIError, /Network error/)
      end
    end

    context "with default timeout" do
      it "uses default timeout when not specified" do
        default_client = described_class.new("test_key")
        stub_request(:get, "https://api.exchangerate-api.com/v4/latest/USD")
          .to_return(body: { rates: { "GBP" => 0.76 } }.to_json)

        expect(default_client.get_rate("USD", "GBP")).to eq(0.76)
      end
    end
  end
end
