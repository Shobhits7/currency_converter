# frozen_string_literal: true

require "currency_converter"

RSpec.describe CurrencyConverter::Converter do
  let(:converter) { described_class.new }

  # Simulate a missing exchange rate to trigger the error handling
  before do
    allow_any_instance_of(CurrencyConverter::APIClient)
      .to receive(:get_rate)
      .and_raise(CurrencyConverter::RateNotFoundError, "EUR rate not available")
  end

  it "raises an APIError if the conversion fails due to missing rate" do
    expect { converter.convert(100, "USD", "EUR") }.to raise_error(CurrencyConverter::APIError, /Conversion failed/)
  end

  it "performs the conversion successfully when rate is available" do
    # Simulate a successful exchange rate retrieval
    allow_any_instance_of(CurrencyConverter::APIClient)
      .to receive(:get_rate)
      .and_return(0.85)

    result = converter.convert(100, "USD", "EUR")
    expect(result).to eq(85.0)
  end
end
