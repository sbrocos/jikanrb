## [Unreleased]

## [0.3.0] - 2026-01-31

### Added
- **Fluent API** for accessing sub-resources with chainable methods
- `BaseResource` class providing common functionality for all resources
- `AnimeResource` with 14 sub-resource methods:
  - `info(full: false)` - Basic/full anime details
  - `characters` - Characters and voice actors
  - `staff` - Staff members
  - `episodes(page: nil)` - Episodes with pagination
  - `news` - Related news articles
  - `forum` - Forum topics
  - `videos` - PVs, episodes, music videos
  - `pictures` - Anime pictures
  - `statistics` - User statistics
  - `recommendations` - User recommendations
  - `relations` - Related anime/manga
  - `themes` - Opening/ending themes
  - `external` - External links
  - `streaming` - Streaming platform links
- `MangaResource` with 9 sub-resource methods:
  - `info(full: false)` - Basic/full manga details
  - `characters` - Characters
  - `news` - Related news articles
  - `forum` - Forum topics
  - `pictures` - Manga pictures
  - `statistics` - User statistics
  - `recommendations` - User recommendations
  - `relations` - Related anime/manga
  - `external` - External links
- `CharacterResource` with 5 sub-resource methods:
  - `info(full: false)` - Basic/full character details
  - `animes` - Anime appearances
  - `mangas` - Manga appearances
  - `voices` - Voice actors
  - `pictures` - Character pictures
- `PersonResource` with 5 sub-resource methods:
  - `info(full: false)` - Basic/full person details
  - `animes` - Anime staff positions
  - `mangas` - Manga work
  - `voices` - Voice acting roles
  - `pictures` - Person pictures

### Changed
- `Client#anime(id)` now returns `AnimeResource` instead of `Hash`
- `Client#manga(id)` now returns `MangaResource` instead of `Hash`
- `Client#character(id)` now returns `CharacterResource` instead of `Hash`
- `Client#person(id)` now returns `PersonResource` instead of `Hash`

### Breaking Changes
- Removed `full:` parameter from `anime`, `manga`, `character`, and `person` methods
- Use `.info` or `.info(full: true)` for the previous behavior:
  ```ruby
  # Before (v0.2.x)
  client.anime(1)
  client.anime(1, full: true)

  # After (v0.3.0+)
  client.anime(1).info
  client.anime(1).info(full: true)
  ```

### Documentation
- Complete YARD documentation for all resource classes
- Updated README with fluent API examples
- Added migration guide for breaking changes

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
