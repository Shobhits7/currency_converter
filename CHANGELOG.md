## [1.2.1] - 2026-01-10

### Changed
- **Gemspec Metadata**: Added metadata links for better RubyGems integration
  - Added changelog_uri pointing to CHANGELOG.md
  - Added bug_tracker_uri pointing to GitHub Issues
  - Added documentation_uri pointing to README.md
  - Added wiki_uri pointing to GitHub Wiki
  - These links now appear on the RubyGems.org page for better discoverability
- **README Badges**: Added professional badges to README
  - Gem Version badge (shows current version)
  - Downloads badge (shows total download count)
  - License badge (shows MIT license)

### Notes
- No functional changes - this is a metadata-only release
- Improves gem discoverability and professionalism on RubyGems.org

## [1.2.0] - 2026-01-10

### Added
- **v6 API Support**: Migrated from deprecated v4 to v6 ExchangeRate-API
  - Dual-mode operation: authenticated (with API key) and open access (without API key)
  - API key is now optional - gem works perfectly without it
  - Improved error handling for v6-specific errors (invalid-key, quota-reached, inactive-account, unsupported-code)
  - Helpful logging to inform users which API mode they're using
- **Input Validation**: Comprehensive validation for all conversion inputs
  - Validates amounts (rejects nil, negative, and non-numeric values)
  - Validates currency codes (enforces 3-letter uppercase ISO 4217 format)
  - New error classes: `InvalidAmountError` and `InvalidCurrencyError`
  - Clear, actionable error messages for debugging
- **HTTP Timeout Configuration**: Configurable timeout to prevent hanging requests
  - Default timeout: 10 seconds
  - Prevents indefinite hangs on slow/dead connections
  - New `TimeoutError` exception for timeout scenarios
  - Configurable via `CurrencyConverter.configure { |c| c.timeout = 15 }`
- **Test Infrastructure**: Achieved 100% code coverage
  - SimpleCov integration for coverage tracking
  - 43 comprehensive test examples covering all code paths
  - Manual integration test script for real API verification
  - Zero RuboCop offenses

### Fixed
- **Cache Duration Bug**: Cache expiration now works correctly
  - Previously configured `cache_duration` was ignored
  - Cache now properly expires after the configured duration
  - Fixed by passing `expires_in` parameter to ActiveSupport::Cache
- **API Key Usage**: API key is now properly used in authenticated requests
  - v1.1.0 configured but never used the API key
  - v6 authenticated mode now includes key in URL path

### Changed
- **Breaking Change**: Migrated from v4 to v6 API
  - v4 endpoint: `https://api.exchangerate-api.com/v4/latest/{currency}`
  - v6 authenticated: `https://v6.exchangerate-api.com/v6/{API_KEY}/latest/{currency}`
  - v6 open access: `https://open.er-api.com/v6/latest/{currency}`
  - No breaking changes for existing users - works with or without API key
- Code quality improvements: All RuboCop offenses fixed

### Migration Guide from v1.1.0 to v1.2.0
- **No code changes required** - fully backward compatible
- API key is now optional (but recommended for better rate limits)
- Invalid inputs (nil, negative amounts, invalid currency codes) will now raise validation errors
- Cache will now properly expire after configured duration (was broken in v1.1.0)
- Set timeout if needed: `CurrencyConverter.configure { |c| c.timeout = 15 }`

## [1.1.0] - 2024-11-13
### Added
- Added caching support for better performance.
- Introduced error handling for missing exchange rates.
### Fixed
- Fixed issue with conversion when rate is missing.

## [0.1.0] - 2024-11-11

- Initial release
