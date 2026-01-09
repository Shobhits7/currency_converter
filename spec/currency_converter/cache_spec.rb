# frozen_string_literal: true

require "currency_converter"

RSpec.describe CurrencyConverter::Cache do
  before do
    CurrencyConverter.configure do |config|
      config.cache_duration = 60 # Set cache duration for testing
    end
  end

  let(:cache) { described_class.new }

  describe "#fetch" do
    it "caches values and returns cached value on subsequent calls" do
      result = cache.fetch("test_key", expires_in: 60) { "original_value" }
      expect(result).to eq("original_value")

      # Second fetch should return cached value
      cached_result = cache.fetch("test_key", expires_in: 60) { "new_value" }
      expect(cached_result).to eq("original_value")
    end

    it "respects the expires_in parameter" do
      # Cache with 1 second expiration
      result = cache.fetch("expiring_key", expires_in: 1) { "first_value" }
      expect(result).to eq("first_value")

      # Immediately fetching should return cached value
      cached_result = cache.fetch("expiring_key", expires_in: 1) { "second_value" }
      expect(cached_result).to eq("first_value")

      # After expiration, should return new value
      sleep 1.1 # Wait for expiration
      expired_result = cache.fetch("expiring_key", expires_in: 1) { "third_value" }
      expect(expired_result).to eq("third_value")
    end

    it "returns fresh data when no expires_in is provided" do
      result = cache.fetch("no_expiry_key") { "value_1" }
      expect(result).to eq("value_1")

      # Without expiration, values stay cached indefinitely
      cached_result = cache.fetch("no_expiry_key") { "value_2" }
      expect(cached_result).to eq("value_1")
    end

    it "handles different cache keys independently" do
      result1 = cache.fetch("key_1", expires_in: 60) { "value_1" }
      result2 = cache.fetch("key_2", expires_in: 60) { "value_2" }

      expect(result1).to eq("value_1")
      expect(result2).to eq("value_2")

      # Both should be cached
      cached_result1 = cache.fetch("key_1", expires_in: 60) { "new_value_1" }
      cached_result2 = cache.fetch("key_2", expires_in: 60) { "new_value_2" }

      expect(cached_result1).to eq("value_1")
      expect(cached_result2).to eq("value_2")
    end
  end
end
