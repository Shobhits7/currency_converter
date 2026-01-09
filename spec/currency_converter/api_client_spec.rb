# frozen_string_literal: true

require "currency_converter"
require "webmock/rspec"

RSpec.describe CurrencyConverter::APIClient do
  describe "#get_rate" do
    context "with authenticated v6 API (with API key)" do
      let(:client) { described_class.new("test_api_key_123", timeout: 5) }

      it "returns the exchange rate for a valid currency pair" do
        stub_request(:get, "https://v6.exchangerate-api.com/v6/test_api_key_123/latest/USD")
          .to_return(body: { result: "success", conversion_rates: { "EUR" => 0.85 } }.to_json)

        expect(client.get_rate("USD", "EUR")).to eq(0.85)
      end

      it "uses custom timeout configuration" do
        custom_client = described_class.new("test_api_key_123", timeout: 15)
        stub_request(:get, "https://v6.exchangerate-api.com/v6/test_api_key_123/latest/USD")
          .to_return(body: { result: "success", conversion_rates: { "EUR" => 0.85 } }.to_json)

        expect(custom_client.get_rate("USD", "EUR")).to eq(0.85)
      end

      it "raises APIError for invalid API key" do
        stub_request(:get, "https://v6.exchangerate-api.com/v6/test_api_key_123/latest/USD")
          .to_return(body: { result: "error", "error-type" => "invalid-key" }.to_json)

        expect { client.get_rate("USD", "EUR") }
          .to raise_error(CurrencyConverter::APIError, /Invalid API key/)
      end

      it "raises APIError for quota reached" do
        stub_request(:get, "https://v6.exchangerate-api.com/v6/test_api_key_123/latest/USD")
          .to_return(body: { result: "error", "error-type" => "quota-reached" }.to_json)

        expect { client.get_rate("USD", "EUR") }
          .to raise_error(CurrencyConverter::APIError, /rate limit quota reached/)
      end

      it "raises APIError for inactive account" do
        stub_request(:get, "https://v6.exchangerate-api.com/v6/test_api_key_123/latest/USD")
          .to_return(body: { result: "error", "error-type" => "inactive-account" }.to_json)

        expect { client.get_rate("USD", "EUR") }
          .to raise_error(CurrencyConverter::APIError, /account is inactive/)
      end
    end

    context "with open access v6 API (without API key)" do
      let(:client) { described_class.new(nil, timeout: 5) }

      it "returns the exchange rate using open access endpoint" do
        stub_request(:get, "https://open.er-api.com/v6/latest/USD")
          .to_return(body: { result: "success", rates: { "EUR" => 0.85 } }.to_json)

        expect(client.get_rate("USD", "EUR")).to eq(0.85)
      end

      it "works with empty string API key" do
        empty_key_client = described_class.new("", timeout: 5)
        stub_request(:get, "https://open.er-api.com/v6/latest/USD")
          .to_return(body: { result: "success", rates: { "GBP" => 0.76 } }.to_json)

        expect(empty_key_client.get_rate("USD", "GBP")).to eq(0.76)
      end

      it "supports conversion_rates field (v6 format)" do
        stub_request(:get, "https://open.er-api.com/v6/latest/USD")
          .to_return(body: { result: "success", conversion_rates: { "JPY" => 156.84 } }.to_json)

        expect(client.get_rate("USD", "JPY")).to eq(156.84)
      end
    end

    context "with error scenarios" do
      let(:client) { described_class.new("test_key", timeout: 5) }

      it "raises a RateNotFoundError if the rate is missing" do
        stub_request(:get, "https://v6.exchangerate-api.com/v6/test_key/latest/USD")
          .to_return(body: { result: "success", conversion_rates: {} }.to_json)

        expect { client.get_rate("USD", "EUR") }
          .to raise_error(CurrencyConverter::RateNotFoundError, /EUR rate not available/)
      end

      it "raises an APIError for invalid JSON response" do
        stub_request(:get, "https://v6.exchangerate-api.com/v6/test_key/latest/USD")
          .to_return(body: "invalid json")

        expect { client.get_rate("USD", "EUR") }
          .to raise_error(CurrencyConverter::APIError, /Invalid API response format/)
      end

      it "raises a TimeoutError when request times out" do
        stub_request(:get, "https://v6.exchangerate-api.com/v6/test_key/latest/USD")
          .to_timeout

        expect { client.get_rate("USD", "EUR") }
          .to raise_error(CurrencyConverter::TimeoutError, /Request timed out/)
      end

      it "raises an APIError for network errors" do
        stub_request(:get, "https://v6.exchangerate-api.com/v6/test_key/latest/USD")
          .to_raise(SocketError.new("Failed to open TCP connection"))

        expect { client.get_rate("USD", "EUR") }
          .to raise_error(CurrencyConverter::APIError, /Network error/)
      end

      it "raises an APIError for unsupported currency code" do
        stub_request(:get, "https://v6.exchangerate-api.com/v6/test_key/latest/USD")
          .to_return(body: { result: "error", "error-type" => "unsupported-code" }.to_json)

        expect { client.get_rate("USD", "XYZ") }
          .to raise_error(CurrencyConverter::APIError, /Unsupported currency code/)
      end
    end

    context "with default timeout" do
      it "uses default timeout when not specified" do
        default_client = described_class.new("test_key")
        stub_request(:get, "https://v6.exchangerate-api.com/v6/test_key/latest/USD")
          .to_return(body: { result: "success", conversion_rates: { "GBP" => 0.76 } }.to_json)

        expect(default_client.get_rate("USD", "GBP")).to eq(0.76)
      end
    end
  end
end
