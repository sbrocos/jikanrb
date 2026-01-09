# Jikanrb

[![Gem Version](https://badge.fury.io/rb/jikanrb.svg)](https://badge.fury.io/rb/jikanrb)
[![CI](https://github.com/tuusuario/jikanrb/actions/workflows/main.yml/badge.svg)](https://github.com/tuusuario/jikanrb/actions)

A modern Ruby client for the [Jikan API v4](https://jikan.moe/) - the unofficial MyAnimeList API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jikanrb'
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
require 'jikanrb'

# Get anime by ID
anime = Jikanrb.anime(1)

# Access data using strings or symbols (Indifferent Access)
puts anime["data"]["title"] # => "Cowboy Bebop"
puts anime[:data][:title]   # => "Cowboy Bebop"

# Get full anime info (includes relations, theme songs, etc.)
anime = Jikanrb.anime(1, full: true)

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

# All methods available
client.anime(1)
client.manga(1)
client.character(1)
client.person(1)
client.search_anime("One Piece", type: "tv", status: "airing")
client.top_anime(type: "tv", filter: "bypopularity")
client.season(2024, "winter")
client.season_now
client.schedules(day: "monday")
```

### Configuration in Rails

You can configure the gem globally in an initializer (e.g., `config/initializers/jikanrb.rb`):

```ruby
# config/initializers/jikanrb.rb
Jikanrb.configure do |config|
  config.read_timeout = 20
  config.max_retries = 3
  # config.logger = Rails.logger # Use Rails logger
end
```

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

### Available Methods

| Method | Description |
| :--- | :--- |
| `anime(id, full: false)` | Get anime by MAL ID |
| `manga(id, full: false)` | Get manga by MAL ID |
| `character(id, full: false)` | Get character by MAL ID |
| `person(id, full: false)` | Get person by MAL ID |
| `search_anime(query, **params)` | Search anime |
| `search_manga(query, **params)` | Search manga |
| `top_anime(type:, filter:, page:)` | Top anime list |
| `top_manga(type:, filter:, page:)` | Top manga list |
| `season(year, season, page:)` | Anime by season |
| `season_now(page:)` | Current season anime |
| `schedules(day:)` | Weekly schedule |

### Error Handling

```ruby
begin
  anime = Jikanrb.anime(999999999)
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

### Pagination

The gem provides convenient pagination helpers for working with paginated endpoints:

```ruby
# Automatic pagination - iterates through all pages
client = Jikanrb::Client.new
paginator = client.paginate(:top_anime, type: 'tv')

# Get all items (will fetch all pages)
all_anime = paginator.all

# Iterate through all pages lazily
paginator.each do |anime|
  puts "#{anime['title']} - Score: #{anime['score']}"
end

# Get items from first 3 pages only
first_three_pages = paginator.take_pages(3)

# Manual pagination with pagination info
response = client.top_anime(page: 1)
pagination = client.pagination_info(response)

puts "Current page: #{pagination.current_page}"
puts "Total pages: #{pagination.total_pages}"
puts "Items per page: #{pagination.per_page}"
puts "Has next page: #{pagination.has_next_page?}"
puts "Has previous page: #{pagination.has_previous_page?}"
puts "Next page number: #{pagination.next_page}" if pagination.has_next_page?
```

### Rate Limiting

Jikan API allows **60 requests per minute**. This gem includes automatic retry with exponential backoff for rate limit errors (429).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Useful Commands

```bash
# Install dependencies
bin/setup

# Run tests
bundle exec rspec

# Interactive console
bin/console

# Linting
bundle exec rubocop
```

## Acknowledgments

This gem is inspired by [jikan.rb](https://github.com/Zerocchi/jikan.rb) by Zerocchi, which wrapped the Jikan API v3.

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/[USERNAME]/jikanrb>. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/jikanrb/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Jikanrb project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/jikanrb/blob/main/CODE_OF_CONDUCT.md).
