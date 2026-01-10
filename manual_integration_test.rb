#!/usr/bin/env ruby
# frozen_string_literal: true

# Manual Integration Test for CurrencyConverter v1.2.0
# This script tests the gem with real API calls

$LOAD_PATH.unshift File.expand_path("lib", __dir__)
require "currency_converter"

puts "=" * 80
puts "CurrencyConverter v1.2.0 - Manual Integration Test"
puts "=" * 80
puts

# Test 1: Open Access Mode (without API key)
puts "TEST 1: Open Access Mode (no API key)"
puts "-" * 80
CurrencyConverter.configure do |config|
  config.api_key = nil
  config.cache_duration = 60
  config.timeout = 10
end

converter = CurrencyConverter::Converter.new
begin
  result = converter.convert(100, "USD", "EUR")
  puts "✅ Convert 100 USD to EUR: #{result} EUR"
  puts "   API Mode: v6 Open Access"
rescue StandardError => e
  puts "❌ FAILED: #{e.class} - #{e.message}"
end
puts

# Test 2: Cache functionality
puts "TEST 2: Cache Hit (should use cached value)"
puts "-" * 80
begin
  result2 = converter.convert(100, "USD", "EUR")
  puts "✅ Second conversion (cached): #{result2} EUR"
  puts "   Should be instant (from cache)"
rescue StandardError => e
  puts "❌ FAILED: #{e.class} - #{e.message}"
end
puts

# Test 3: Different currency pair
puts "TEST 3: Different Currency Pair"
puts "-" * 80
begin
  result = converter.convert(100, "USD", "GBP")
  puts "✅ Convert 100 USD to GBP: #{result} GBP"
rescue StandardError => e
  puts "❌ FAILED: #{e.class} - #{e.message}"
end
puts

# Test 4: Input Validation - Negative Amount
puts "TEST 4: Input Validation - Negative Amount"
puts "-" * 80
begin
  converter.convert(-100, "USD", "EUR")
  puts "❌ FAILED: Should have raised InvalidAmountError"
rescue CurrencyConverter::InvalidAmountError => e
  puts "✅ Correctly raised InvalidAmountError: #{e.message}"
rescue StandardError => e
  puts "❌ FAILED: Wrong error type - #{e.class}"
end
puts

# Test 5: Input Validation - Invalid Currency Code
puts "TEST 5: Input Validation - Invalid Currency Code"
puts "-" * 80
begin
  converter.convert(100, "usd", "EUR")
  puts "❌ FAILED: Should have raised InvalidCurrencyError"
rescue CurrencyConverter::InvalidCurrencyError => e
  puts "✅ Correctly raised InvalidCurrencyError: #{e.message}"
rescue StandardError => e
  puts "❌ FAILED: Wrong error type - #{e.class}"
end
puts

# Test 6: Input Validation - Nil Amount
puts "TEST 6: Input Validation - Nil Amount"
puts "-" * 80
begin
  converter.convert(nil, "USD", "EUR")
  puts "❌ FAILED: Should have raised InvalidAmountError"
rescue CurrencyConverter::InvalidAmountError => e
  puts "✅ Correctly raised InvalidAmountError: #{e.message}"
rescue StandardError => e
  puts "❌ FAILED: Wrong error type - #{e.class}"
end
puts

# Test 7: Zero amount (edge case, should work)
puts "TEST 7: Zero Amount (should work)"
puts "-" * 80
begin
  result = converter.convert(0, "USD", "EUR")
  puts "✅ Convert 0 USD to EUR: #{result} EUR"
rescue StandardError => e
  puts "❌ FAILED: #{e.class} - #{e.message}"
end
puts

# Test 8: Decimal amounts
puts "TEST 8: Decimal Amounts"
puts "-" * 80
begin
  result = converter.convert(99.99, "USD", "EUR")
  puts "✅ Convert 99.99 USD to EUR: #{result} EUR"
rescue StandardError => e
  puts "❌ FAILED: #{e.class} - #{e.message}"
end
puts

# Test 9: Large numbers
puts "TEST 9: Large Numbers"
puts "-" * 80
begin
  result = converter.convert(1_000_000, "USD", "EUR")
  puts "✅ Convert 1,000,000 USD to EUR: #{result} EUR"
rescue StandardError => e
  puts "❌ FAILED: #{e.class} - #{e.message}"
end
puts

# Test 10: Performance - Multiple Conversions
puts "TEST 10: Performance Test (10 conversions)"
puts "-" * 80
start_time = Time.now
successes = 0
begin
  10.times do
    converter.convert(100, "USD", "EUR")
    successes += 1
  end
  elapsed = Time.now - start_time
  puts "✅ Completed 10 conversions in #{elapsed.round(3)} seconds"
  puts "   Average: #{(elapsed / 10 * 1000).round(2)}ms per conversion"
  puts "   (Most should be cached, so very fast)"
rescue StandardError => e
  puts "❌ FAILED after #{successes} conversions: #{e.class} - #{e.message}"
end
puts

puts "=" * 80
puts "Integration Test Complete!"
puts "=" * 80
puts
puts "Note: These tests use real API calls. If they fail, it might be due to:"
puts "  - Network connectivity issues"
puts "  - API rate limiting"
puts "  - API service downtime"
puts
puts "For full test coverage, run: bundle exec rake spec"
