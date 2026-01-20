## [Unreleased]

## [0.2.2] - 2026-01-20

### Fixed
- Fixed an issue where API requests were missing the `/v4` version segment in the URL.

## [0.2.1] - 2026-01-10

### Changed
  - Changed info about gem for Ru8byGems
  
## [0.2.0] - 2026-01-10

### Added
- New endpoint methods:
  - `character(id, full: false)` - Get character information
  - `person(id, full: false)` - Get person information
  - `top_anime(type:, filter:, page:)` - Get top anime rankings
  - `top_manga(type:, filter:, page:)` - Get top manga rankings
  - `season(year, season, page:)` - Get anime by season
  - `season_now(page:)` - Get current season anime
  - `schedules(day:)` - Get anime schedules
- Pagination helper module (`Jikanrb::Pagination`) with `each_page` iterator
- Global convenience methods (`Jikanrb.anime(1)`, `Jikanrb.search_anime("Naruto")`, etc.)
- `IndifferentHash` utility for flexible hash access (symbol/string keys)
- Enhanced error handling with custom exception classes:
  - `ResourceNotFoundError` (404)
  - `BadRequestError` (400)
  - `RateLimitError` (429)
  - `ServerError` (5xx)
  - `TimeoutError`
  - `ParseError`
- Retry mechanism with exponential backoff for transient errors
- Rate limiting awareness (respects Retry-After headers)

### Changed
- Response hashes now support both symbol and string key access
- Configuration system supports both global and per-instance settings
- Improved test coverage (63 examples, all passing)
- All tests use WebMock stubs for independence from external API

### Documentation
- Complete README with usage examples
- YARD documentation for all public methods
- RuboCop compliant (0 offenses)

## [0.1.0] - 2026-01-08

### Added
- Initial release
- Basic client with Faraday
- Core endpoints: `anime(id)`, `manga(id)`, `search_anime`, `search_manga`
- Configuration support
- Basic error handling
