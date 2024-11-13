# frozen_string_literal: true

# spec/converter_spec.rb
require "currency_converter"

RSpec.describe CurrencyConverter::Converter do
  let(:converter) { CurrencyConverter::Converter.new("fake_api_key") }

  it "converts currency correctly" do
    allow(converter).to receive(:fetch_exchange_rate).and_return(0.84)
    expect(converter.convert(100, "USD", "EUR")).to eq(84.0)
  end

  it "raises an error for unsupported currency" do
    allow(converter).to receive(:fetch_exchange_rate).and_raise("Currency not supported or API error")
    expect { converter.convert(100, "USD", "XYZ") }.to raise_error("Currency not supported or API error")
  end
end
