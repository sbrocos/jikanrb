# frozen_string_literal: true

module Jikanrb
  # Base error for the gem
  class Error < StandardError
    attr_reader :response, :status

    def initialize(message = nil, response: nil, status: nil)
      @response = response
      @status = status
      super(message)
    end
  end

  # Configuration error
  class ConfigurationError < Error; end

  # Specific HTTP errors
  class ClientError < Error; end

  # 400 - Bad Request
  class BadRequestError < ClientError; end

  # 404 - Not Found
  class NotFoundError < ClientError; end

  # 405 - Method Not Allowed
  class MethodNotAllowedError < ClientError; end

  # 429 - Rate Limit Exceeded
  class RateLimitError < ClientError
    attr_reader :retry_after

    def initialize(message = nil, response: nil, status: nil, retry_after: nil)
      @retry_after = retry_after
      super(message, response: response, status: status)
    end
  end

  # 5xx - Server errors
  class ServerError < Error; end

  # Connection error (timeout, network issues)
  class ConnectionError < Error; end

  # Error parsing JSON
  class ParseError < Error; end
end
