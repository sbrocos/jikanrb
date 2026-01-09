# frozen_string_literal: true

module Jikanrb
  # Configuration class for Jikanrb client.
  # Allows customization of timeouts, retries, and other HTTP client settings.
  #
  # @example
  #   config = Jikanrb::Configuration.new
  #   config.read_timeout = 15
  #   config.max_retries = 5
  class Configuration
    # Base URL for Jikan v4 API
    DEFAULT_BASE_URL = 'https://api.jikan.moe/v4'

    # Default timeouts (in seconds)
    DEFAULT_OPEN_TIMEOUT = 5
    DEFAULT_READ_TIMEOUT = 10

    # Rate limit: Jikan allows 60 requests/minute
    DEFAULT_MAX_RETRIES = 3
    DEFAULT_RETRY_INTERVAL = 1

    attr_accessor :base_url,
                  :open_timeout,
                  :read_timeout,
                  :max_retries,
                  :retry_interval,
                  :user_agent,
                  :logger

    def initialize
      @base_url = DEFAULT_BASE_URL
      @open_timeout = DEFAULT_OPEN_TIMEOUT
      @read_timeout = DEFAULT_READ_TIMEOUT
      @max_retries = DEFAULT_MAX_RETRIES
      @retry_interval = DEFAULT_RETRY_INTERVAL
      @user_agent = "Jikanrb Ruby Gem/#{Jikanrb::VERSION}"
      @logger = nil
    end
  end
end
