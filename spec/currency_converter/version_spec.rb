# frozen_string_literal: true

require "currency_converter"

RSpec.describe CurrencyConverter do
  describe "VERSION" do
    it "has a version number" do
      expect(CurrencyConverter::VERSION).not_to be nil
    end

    it "has correct version format" do
      expect(CurrencyConverter::VERSION).to match(/\d+\.\d+\.\d+/)
    end
  end
end
