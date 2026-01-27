# frozen_string_literal: true

require_relative 'jikanrb/version'
require_relative 'jikanrb/configuration'
require_relative 'jikanrb/errors'
require_relative 'jikanrb/pagination'
require_relative 'jikanrb/client'
require_relative 'jikanrb/utils'

# Resources module - Fluent API for accessing sub-resources
require_relative 'jikanrb/resources/base_resource'

# Jikanrb is a modern Ruby wrapper for the Jikan REST API v4.
# Provides easy access to anime, manga, characters, and more from MyAnimeList.
#
# @example Basic usage
#   client = Jikanrb::Client.new
#   anime = client.anime(1) # Cowboy Bebop
#
# @example Using global configuration
#   Jikanrb.configure do |config|
#     config.read_timeout = 15
#   end
#   anime = Jikanrb.anime(1)
module Jikanrb
  class << self
    attr_writer :configuration

    # Global configuration for the gem
    #
    # @return [Configuration] Current configuration
    def configuration
      @configuration ||= Configuration.new
    end

    # Configures the gem with a block
    #
    # @example
    #   Jikanrb.configure do |config|
    #     config.read_timeout = 15
    #     config.logger = Logger.new($stdout)
    #   end
    #
    # @yield [config] Configuration block
    # @yieldparam config [Configuration] Configuration object
    def configure
      yield(configuration)
    end

    # Resets configuration to default values
    #
    # @return [Configuration] New configuration
    def reset_configuration!
      @configuration = Configuration.new
    end

    # Default client using global configuration
    #
    # @return [Client] Configured client
    def client
      @client ||= Client.new { |config| configure_client(config) }
    end

    # Resets the client (useful after changing configuration)
    #
    # @return [nil]
    def reset_client!
      @client = nil
    end

    # Convenience methods that delegate to the default client
    # Allows using Jikanrb.anime(1) directly

    # @see Client#anime
    def anime(id, full: false)
      client.anime(id, full: full)
    end

    # @see Client#manga
    def manga(id, full: false)
      client.manga(id, full: full)
    end

    # @see Client#character
    def character(id, full: false)
      client.character(id, full: full)
    end

    # @see Client#person
    def person(id, full: false)
      client.person(id, full: full)
    end

    # @see Client#search_anime
    def search_anime(query, **params)
      client.search_anime(query, **params)
    end

    # @see Client#search_manga
    def search_manga(query, **params)
      client.search_manga(query, **params)
    end

    # @see Client#top_anime
    def top_anime(type: nil, filter: nil, page: 1)
      client.top_anime(type: type, filter: filter, page: page)
    end

    # @see Client#top_manga
    def top_manga(type: nil, filter: nil, page: 1)
      client.top_manga(type: type, filter: filter, page: page)
    end

    # @see Client#season
    def season(year, season, page: 1)
      client.season(year, season, page: page)
    end

    # @see Client#season_now
    def season_now(page: 1)
      client.season_now(page: page)
    end

    # @see Client#schedules
    def schedules(day: nil)
      client.schedules(day: day)
    end

    private

    # Configures a client instance with global configuration settings
    #
    # @param config [Configuration] Client configuration object
    # @return [void]
    # rubocop:disable Metrics/AbcSize
    def configure_client(config)
      config.base_url = configuration.base_url
      config.open_timeout = configuration.open_timeout
      config.read_timeout = configuration.read_timeout
      config.max_retries = configuration.max_retries
      config.retry_interval = configuration.retry_interval
      config.user_agent = configuration.user_agent
      config.logger = configuration.logger
    end
    # rubocop:enable Metrics/AbcSize
  end
end
