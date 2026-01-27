# frozen_string_literal: true

require 'faraday'
require 'faraday/retry'
require 'json'

module Jikanrb
  # Main HTTP client for interacting with the Jikan API v4.
  # Handles requests, rate limiting, retries, and error handling.
  #
  # @example Basic usage
  #   client = Jikanrb::Client.new
  #   anime = client.anime(1)
  #
  # @example With custom configuration
  #   client = Jikanrb::Client.new do |config|
  #     config.read_timeout = 15
  #     config.max_retries = 5
  #   end
  class Client
    attr_reader :config

    # Initializes the client with optional configuration
    #
    # @example With default configuration
    #   client = Jikanrb::Client.new
    #
    # @example With custom configuration
    #   client = Jikanrb::Client.new do |config|
    #     config.base_url = "https://api.jikan.moe/v4"
    #     config.read_timeout = 15
    #   end
    #
    # @yield [config] Optional block to configure the client
    # @yieldparam config [Configuration] Configuration object
    def initialize
      @config = Configuration.new
      yield(@config) if block_given?
    end

    # Performs a GET request
    #
    # @param path [String] Endpoint path (e.g., "/anime/1")
    # @param params [Hash] Query string parameters
    # @return [Hash] Response parsed as Hash
    def get(path, params = {})
      request(:get, path, params)
    end

    # Anime information by ID
    #
    # @param id [Integer] Anime ID on MyAnimeList
    # @param full [Boolean] If true, returns extended information
    # @return [Hash] Anime data
    def anime(id, full: false)
      path = full ? "anime/#{id}/full" : "anime/#{id}"
      get(path)
    end

    # Manga information by ID
    #
    # @param id [Integer] Manga ID on MyAnimeList
    # @param full [Boolean] If true, returns extended information
    # @return [Hash] Manga data
    def manga(id, full: false)
      path = full ? "manga/#{id}/full" : "manga/#{id}"
      get(path)
    end

    # Returns a CharacterResource for fluent API access to character sub-resources
    #
    # @param id [Integer] Character ID on MyAnimeList
    # @return [Resources::CharacterResource] Character resource for chaining
    #
    # @example Get character info
    #   client.character(1).info
    #   # => { data: { mal_id: 1, name: "Spike Spiegel", ... } }
    #
    # @example Get full character info
    #   client.character(1).info(full: true)
    #
    # @example Get character's anime appearances
    #   client.character(1).animes
    #
    # @example Get character's voice actors
    #   client.character(1).voices
    def character(id)
      Resources::CharacterResource.new(self, id)
    end

    # Returns a PersonResource for fluent API access to person sub-resources
    #
    # @param id [Integer] Person ID on MyAnimeList
    # @return [Resources::PersonResource] Person resource for chaining
    #
    # @example Get person info
    #   client.person(1).info
    #   # => { data: { mal_id: 1, name: "Tomokazu Seki", ... } }
    #
    # @example Get full person info
    #   client.person(1).info(full: true)
    #
    # @example Get person's anime staff positions
    #   client.person(1).animes
    #
    # @example Get person's voice acting roles
    #   client.person(1).voices
    def person(id)
      Resources::PersonResource.new(self, id)
    end

    # Search anime
    #
    # @param query [String] Search term
    # @param params [Hash] Additional filters (type, score, status, etc.)
    # @return [Hash] Search results
    def search_anime(query, **params)
      get('anime', params.merge(q: query))
    end

    # Search manga
    #
    # @param query [String] Search term
    # @param params [Hash] Additional filters
    # @return [Hash] Search results
    def search_manga(query, **params)
      get('manga', params.merge(q: query))
    end

    # Top anime
    #
    # @param type [String, nil] Filter: "tv", "movie", "ova", etc.
    # @param filter [String, nil] Filter: "airing", "upcoming", "bypopularity", etc.
    # @param page [Integer] Page number
    # @return [Hash] List of top anime
    def top_anime(type: nil, filter: nil, page: 1)
      params = { page: page }
      params[:type] = type if type
      params[:filter] = filter if filter
      get('top/anime', params)
    end

    # Top manga
    #
    # @param type [String, nil] Filter: "manga", "novel", "lightnovel", etc.
    # @param filter [String, nil] Filter: "publishing", "upcoming", "bypopularity", etc.
    # @param page [Integer] Page number
    # @return [Hash] List of top manga
    def top_manga(type: nil, filter: nil, page: 1)
      params = { page: page }
      params[:type] = type if type
      params[:filter] = filter if filter
      get('top/manga', params)
    end

    # Seasonal anime
    #
    # @param year [Integer] Year
    # @param season [String] Season: "winter", "spring", "summer", "fall"
    # @param page [Integer] Page number
    # @return [Hash] Seasonal anime
    def season(year, season, page: 1)
      get("seasons/#{year}/#{season}", page: page)
    end

    # Current season
    #
    # @param page [Integer] Page number
    # @return [Hash] Current season anime
    def season_now(page: 1)
      get('seasons/now', page: page)
    end

    # Weekly schedule
    #
    # @param day [String, nil] Day: "monday", "tuesday", etc.
    # @return [Hash] Anime schedule
    def schedules(day: nil)
      path = day ? "schedules/#{day}" : 'schedules'
      get(path)
    end

    # Create a paginator for iterating through all pages of a paginated endpoint
    #
    # @param method [Symbol] Method name to paginate (e.g., :top_anime, :search_anime)
    # @param params [Hash] Parameters to pass to the method
    # @return [Pagination::Paginator] Paginator instance
    #
    # @example Iterate through all top anime
    #   client.paginate(:top_anime, type: 'tv').each do |anime|
    #     puts anime['title']
    #   end
    #
    # @example Get all items as array
    #   all_anime = client.paginate(:search_anime, 'Naruto').all
    #
    # @example Get first 3 pages only
    #   anime = client.paginate(:top_anime).take_pages(3)
    def paginate(method, **params)
      Pagination::Paginator.new(self, method, **params)
    end

    # Extract pagination information from a response
    #
    # @param response [Hash] API response with pagination data
    # @return [Pagination::PaginationInfo] Pagination information
    #
    # @example
    #   result = client.top_anime(page: 1)
    #   pagination = client.pagination_info(result)
    #   puts "Page #{pagination.current_page} of #{pagination.total_pages}"
    def pagination_info(response)
      Pagination::PaginationInfo.new(response)
    end

    private

    # Faraday connection with configuration
    def connection
      @connection ||= Faraday.new(url: config.base_url) do |f|
        configure_connection_options(f)
        configure_connection_headers(f)
        configure_connection_middleware(f)
        f.adapter Faraday.default_adapter
      end
    end

    # Configures connection timeouts
    def configure_connection_options(faraday)
      faraday.options.open_timeout = config.open_timeout
      faraday.options.timeout = config.read_timeout
    end

    # Configures connection headers
    def configure_connection_headers(faraday)
      faraday.headers['User-Agent'] = config.user_agent
      faraday.headers['Accept'] = 'application/json'
    end

    # Configures retry middleware and logger
    def configure_connection_middleware(faraday)
      configure_retry_middleware(faraday)
      faraday.response :logger, config.logger if config.logger
    end

    # Configures retry middleware for rate limiting and transient errors
    def configure_retry_middleware(faraday)
      faraday.request :retry,
                      max: config.max_retries,
                      interval: config.retry_interval,
                      interval_randomness: 0.5,
                      backoff_factor: 2,
                      retry_statuses: [429, 500, 502, 503, 504],
                      retry_if: ->(env, _exception) { env.status == 429 }
    end

    # Executes the HTTP request and handles errors
    def request(method, path, params = {})
      response = connection.public_send(method, path, params)
      handle_response(response)
    rescue Faraday::TimeoutError, Faraday::ConnectionFailed => e
      raise ConnectionError, "Connection failed: #{e.message}"
    end

    # Processes the HTTP response
    def handle_response(response)
      return parse_json(response.body) if response.status.between?(200, 299)

      handle_error_response(response)
    end

    # Handles error responses based on status code
    def handle_error_response(response)
      case response.status
      when 400 then raise_bad_request_error(response)
      when 404 then raise_not_found_error(response)
      when 405 then raise_method_not_allowed_error(response)
      when 429 then raise_rate_limit_error(response)
      when 500..599 then raise_server_error(response)
      else raise_unexpected_error(response)
      end
    end

    # Raises a BadRequestError
    def raise_bad_request_error(response)
      raise BadRequestError.new('Bad request', response: response, status: 400)
    end

    # Raises a NotFoundError
    def raise_not_found_error(response)
      raise NotFoundError.new('Resource not found', response: response, status: 404)
    end

    # Raises a MethodNotAllowedError
    def raise_method_not_allowed_error(response)
      raise MethodNotAllowedError.new('Method not allowed', response: response, status: 405)
    end

    # Raises a RateLimitError with retry information
    def raise_rate_limit_error(response)
      retry_after = response.headers['Retry-After']&.to_i
      raise RateLimitError.new(
        "Rate limit exceeded. Retry after #{retry_after || 'unknown'} seconds",
        response: response,
        status: 429,
        retry_after: retry_after
      )
    end

    # Raises a ServerError
    def raise_server_error(response)
      raise ServerError.new("Server error (#{response.status})", response: response, status: response.status)
    end

    # Raises a generic Error for unexpected status codes
    def raise_unexpected_error(response)
      raise Error.new("Unexpected response (#{response.status})", response: response, status: response.status)
    end

    # Parses the JSON response
    def parse_json(body)
      return {} if body.nil? || body.empty?

      parsed = JSON.parse(body)
      Jikanrb::IndifferentHash.new(parsed)
    rescue JSON::ParserError => e
      raise ParseError, "Failed to parse JSON: #{e.message}"
    end
  end
end
