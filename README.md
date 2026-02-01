# Jikanrb

[![Gem Version](https://badge.fury.io/rb/jikanrb.svg)](https://badge.fury.io/rb/jikanrb)
[![CI](https://github.com/sbrocos/jikanrb/actions/workflows/main.yml/badge.svg)](https://github.com/sbrocos/jikanrb/actions)

A modern Ruby client for the [Jikan API v4](https://jikan.moe/) - the unofficial MyAnimeList API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "jikanrb"
```

And then execute:

```bash
bundle install
```

Or install it yourself:

```bash
gem install jikanrb
```

## Usage

### Quick Start

```ruby
require "jikanrb"

# Get anime info using fluent API
anime = Jikanrb.anime(1).info
puts anime[:data][:title]  # => "Cowboy Bebop"

# Get full anime info (includes relations, theme songs, etc.)
anime = Jikanrb.anime(1).info(full: true)

# Search anime
results = Jikanrb.search_anime("Naruto")
results[:data].each do |anime|
  puts "#{anime[:title]} - Score: #{anime[:score]}"
end
```

### Using a Client Instance

```ruby
client = Jikanrb::Client.new do |config|
  config.read_timeout = 15
  config.max_retries = 5
end

# Fluent API for resources
client.anime(1).info
client.manga(1).info
client.character(1).info
client.person(1).info

# Search and listings
client.search_anime("One Piece", type: "tv", status: "airing")
client.top_anime(type: "tv", filter: "bypopularity")
client.season(2024, "winter")
client.season_now
client.schedules(day: "monday")
```

## Fluent API (v1.1.0+)

Access sub-resources using the fluent interface for cleaner, chainable code.

### Anime

```ruby
client = Jikanrb::Client.new

# Basic and full info
client.anime(1).info                # GET /anime/1
client.anime(1).info(full: true)    # GET /anime/1/full

# Sub-resources
client.anime(1).characters          # Characters and voice actors
client.anime(1).staff               # Staff members
client.anime(1).episodes            # Episodes (first page)
client.anime(1).episodes(page: 2)   # Episodes (page 2)
client.anime(1).news                # News articles
client.anime(1).forum               # Forum topics
client.anime(1).videos              # PVs, episodes, music videos
client.anime(1).pictures            # Pictures
client.anime(1).statistics          # User statistics
client.anime(1).recommendations     # User recommendations
client.anime(1).relations           # Related anime/manga
client.anime(1).themes              # Opening/ending themes
client.anime(1).external            # External links
client.anime(1).streaming           # Streaming platform links
```

### Manga

```ruby
client.manga(1).info                # GET /manga/1
client.manga(1).info(full: true)    # GET /manga/1/full
client.manga(1).characters          # Characters
client.manga(1).news                # News articles
client.manga(1).forum               # Forum topics
client.manga(1).pictures            # Pictures
client.manga(1).statistics          # User statistics
client.manga(1).recommendations     # User recommendations
client.manga(1).relations           # Related anime/manga
client.manga(1).external            # External links
```

### Characters

```ruby
client.character(1).info            # GET /characters/1
client.character(1).info(full: true)# GET /characters/1/full
client.character(1).animes          # Anime appearances
client.character(1).mangas          # Manga appearances
client.character(1).voices          # Voice actors
client.character(1).pictures        # Pictures
```

### People

```ruby
client.person(1).info               # GET /people/1
client.person(1).info(full: true)   # GET /people/1/full
client.person(1).animes             # Anime staff positions
client.person(1).mangas             # Manga work
client.person(1).voices             # Voice acting roles
client.person(1).pictures           # Pictures
```

## Configuration

### Global Configuration

```ruby
Jikanrb.configure do |config|
  config.base_url = "https://api.jikan.moe/v4"   # Default
  config.open_timeout = 5                        # Connection timeout (seconds)
  config.read_timeout = 10                       # Read timeout (seconds)
  config.max_retries = 3                         # Retry on rate limit/server errors
  config.retry_interval = 1                      # Initial retry delay (seconds)
  config.logger = Logger.new($stdout)            # Optional logging
end
```

### Rails Configuration

Create an initializer (e.g., `config/initializers/jikanrb.rb`):

```ruby
Jikanrb.configure do |config|
  config.read_timeout = 20
  config.max_retries = 3
  config.logger = Rails.logger
end
```

## Available Methods

### Resource Methods (Fluent API)

| Method | Returns | Description |
| :--- | :--- | :--- |
| `anime(id)` | `AnimeResource` | Anime resource for sub-resource access |
| `manga(id)` | `MangaResource` | Manga resource for sub-resource access |
| `character(id)` | `CharacterResource` | Character resource for sub-resource access |
| `person(id)` | `PersonResource` | Person resource for sub-resource access |

### Direct Methods

| Method | Description |
| :--- | :--- |
| `search_anime(query, **params)` | Search anime |
| `search_manga(query, **params)` | Search manga |
| `top_anime(type:, filter:, page:)` | Top anime list |
| `top_manga(type:, filter:, page:)` | Top manga list |
| `season(year, season, page:)` | Anime by season |
| `season_now(page:)` | Current season anime |
| `schedules(day:)` | Weekly schedule |

## Error Handling

```ruby
begin
  anime = Jikanrb.anime(999999999).info
rescue Jikanrb::NotFoundError => e
  puts "Anime not found: #{e.message}"
rescue Jikanrb::RateLimitError => e
  puts "Rate limited! Retry after #{e.retry_after} seconds"
rescue Jikanrb::ConnectionError => e
  puts "Connection failed: #{e.message}"
rescue Jikanrb::Error => e
  puts "Something went wrong: #{e.message}"
end
```

## Pagination

The gem provides convenient pagination helpers for working with paginated endpoints:

```ruby
client = Jikanrb::Client.new

# Automatic pagination - iterates through all pages
paginator = client.paginate(:top_anime, type: "tv")

# Get all items (will fetch all pages)
all_anime = paginator.all

# Iterate through all pages lazily
paginator.each do |anime|
  puts "#{anime["title"]} - Score: #{anime["score"]}"
end

# Get items from first 3 pages only
first_three_pages = paginator.take_pages(3)

# Manual pagination with pagination info
response = client.top_anime(page: 1)
pagination = client.pagination_info(response)

puts "Current page: #{pagination.current_page}"
puts "Total pages: #{pagination.total_pages}"
puts "Has next page: #{pagination.has_next_page?}"
```

## Rate Limiting

Jikan API allows **60 requests per minute**. This gem includes automatic retry with exponential backoff for rate limit errors (429).

## Development

```bash
# Install dependencies
bin/setup

# Run tests
bundle exec rspec

# Run linter
bundle exec rubocop

# Interactive console
bin/console

# Generate documentation
bundle exec yard doc
```

## Acknowledgments

This gem is inspired by [jikan.rb](https://github.com/Zerocchi/jikan.rb) by Zerocchi, which wrapped the Jikan API v3.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sbrocos/jikanrb.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
