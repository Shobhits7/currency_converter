# frozen_string_literal: true

# frozen_string_literal: true

require "currency_converter"

RSpec.describe CurrencyConverter::Cache do
  before do
    CurrencyConverter.configure do |config|
      config.cache_duration = 60 # Set cache duration for testing
    end
  end

  let(:cache) { described_class.new }

  it "caches values for the specified duration" do
    # Cache a value for the key "test_key"
    # rubocop:disable Style/RedundantFetchBlock
    result = cache.fetch("test_key") { 100 }
    expect(result).to eq(100)

    # Try fetching the value again, it should return the cached value
    cached_result = cache.fetch("test_key") { 200 }
    expect(cached_result).to eq(100) # Cached value should be returned
    # rubocop:enable Style/RedundantFetchBlock
  end
end
