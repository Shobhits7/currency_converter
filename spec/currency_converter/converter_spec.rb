# frozen_string_literal: true

require "currency_converter"

RSpec.describe CurrencyConverter::Converter do
  let(:converter) { described_class.new }

  describe "#convert" do
    context "with valid inputs" do
      before do
        allow_any_instance_of(CurrencyConverter::APIClient)
          .to receive(:get_rate)
          .and_return(0.85)
      end

      it "performs the conversion successfully" do
        result = converter.convert(100, "USD", "EUR")
        expect(result).to eq(85.0)
      end

      it "handles zero amount" do
        result = converter.convert(0, "USD", "EUR")
        expect(result).to eq(0.0)
      end

      it "handles decimal amounts" do
        result = converter.convert(100.50, "USD", "EUR")
        expect(result).to eq(85.43)
      end
    end

    context "with API errors" do
      before do
        allow_any_instance_of(CurrencyConverter::APIClient)
          .to receive(:get_rate)
          .and_raise(CurrencyConverter::RateNotFoundError, "EUR rate not available")
      end

      it "raises an APIError if the conversion fails due to missing rate" do
        expect { converter.convert(100, "USD", "EUR") }
          .to raise_error(CurrencyConverter::APIError, /Conversion failed/)
      end

      it "logs error when conversion fails" do
        logger = instance_double(Logger, error: nil, info: nil)
        allow(CurrencyConverter.configuration).to receive(:logger).and_return(logger)

        expect(logger).to receive(:error).with(/Conversion failed/)

        begin
          converter.convert(100, "USD", "EUR")
        rescue CurrencyConverter::APIError
          # Expected error
        end
      end

      it "re-raises StandardError exceptions with logging" do
        allow_any_instance_of(CurrencyConverter::APIClient)
          .to receive(:get_rate)
          .and_raise(StandardError, "Unexpected error")

        logger = instance_double(Logger, error: nil, info: nil)
        allow(CurrencyConverter.configuration).to receive(:logger).and_return(logger)

        expect(logger).to receive(:error).with(/Conversion failed/)

        expect { converter.convert(100, "USD", "EUR") }
          .to raise_error(StandardError, "Unexpected error")
      end
    end

    context "with invalid amount" do
      it "raises InvalidAmountError when amount is nil" do
        expect { converter.convert(nil, "USD", "EUR") }
          .to raise_error(CurrencyConverter::InvalidAmountError, "Amount cannot be nil")
      end

      it "does not log validation errors" do
        logger = instance_double(Logger, error: nil, info: nil)
        allow(CurrencyConverter.configuration).to receive(:logger).and_return(logger)

        expect(logger).not_to receive(:error)

        expect { converter.convert(nil, "USD", "EUR") }
          .to raise_error(CurrencyConverter::InvalidAmountError)
      end

      it "raises InvalidAmountError when amount is not numeric" do
        expect { converter.convert("100", "USD", "EUR") }
          .to raise_error(CurrencyConverter::InvalidAmountError, /Amount must be a number/)
      end

      it "raises InvalidAmountError when amount is negative" do
        expect { converter.convert(-100, "USD", "EUR") }
          .to raise_error(CurrencyConverter::InvalidAmountError, /Amount cannot be negative/)
      end
    end

    context "with invalid currency codes" do
      it "raises InvalidCurrencyError when from_currency is nil" do
        expect { converter.convert(100, nil, "EUR") }
          .to raise_error(CurrencyConverter::InvalidCurrencyError, "from_currency cannot be nil")
      end

      it "raises InvalidCurrencyError when to_currency is nil" do
        expect { converter.convert(100, "USD", nil) }
          .to raise_error(CurrencyConverter::InvalidCurrencyError, "to_currency cannot be nil")
      end

      it "raises InvalidCurrencyError when from_currency is not a string" do
        expect { converter.convert(100, 123, "EUR") }
          .to raise_error(CurrencyConverter::InvalidCurrencyError, /from_currency must be a string/)
      end

      it "raises InvalidCurrencyError when from_currency is empty" do
        expect { converter.convert(100, "", "EUR") }
          .to raise_error(CurrencyConverter::InvalidCurrencyError, "from_currency cannot be empty")
      end

      it "raises InvalidCurrencyError when from_currency is not 3 letters" do
        expect { converter.convert(100, "US", "EUR") }
          .to raise_error(CurrencyConverter::InvalidCurrencyError, /must be a 3-letter uppercase code/)
      end

      it "raises InvalidCurrencyError when from_currency is not uppercase" do
        expect { converter.convert(100, "usd", "EUR") }
          .to raise_error(CurrencyConverter::InvalidCurrencyError, /must be a 3-letter uppercase code/)
      end

      it "raises InvalidCurrencyError when from_currency contains numbers" do
        expect { converter.convert(100, "US1", "EUR") }
          .to raise_error(CurrencyConverter::InvalidCurrencyError, /must be a 3-letter uppercase code/)
      end

      it "raises InvalidCurrencyError when to_currency is invalid" do
        expect { converter.convert(100, "USD", "euro") }
          .to raise_error(CurrencyConverter::InvalidCurrencyError, /must be a 3-letter uppercase code/)
      end
    end
  end
end
