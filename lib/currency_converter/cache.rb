# frozen_string_literal: true

require "active_support/cache"
require "active_support/notifications"

module CurrencyConverter
  # The Cache class is responsible for caching the exchange rates to improve performance.
  # It uses ActiveSupport's MemoryStore for caching.
  class Cache
    def initialize
      @cache = ActiveSupport::Cache::MemoryStore.new
    end

    # Fetches the value from the cache, using the block to provide a default value.
    # @param key [String] the cache key
    # @param block [Proc] the block to execute if the key is not found in cache
    # @return [Object] the cached value
    def fetch(key, &block)
      @cache.fetch(key, &block) # ActiveSupport's cache expects only the key and a block
    end
  end
end
