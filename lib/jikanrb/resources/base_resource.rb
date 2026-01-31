# frozen_string_literal: true

module Jikanrb
  module Resources
    # Base class for all resource classes.
    # Provides common functionality for accessing sub-resources from the Jikan API.
    #
    # @abstract Subclass and implement specific resource methods
    #
    # @example Creating a custom resource
    #   class AnimeResource < BaseResource
    #     def characters
    #       get("anime/#{@id}/characters")
    #     end
    #   end
    class BaseResource
      # @return [Integer] The resource ID
      attr_reader :id

      # Creates a new resource instance
      #
      # @param client [Jikanrb::Client] The client instance to use for requests
      # @param id [Integer] The resource ID on MyAnimeList
      def initialize(client, id)
        @client = client
        @id = id
      end

      private

      # Performs a GET request through the client
      #
      # @param path [String] The API endpoint path
      # @param params [Hash] Optional query parameters
      # @return [Hash] The API response as an IndifferentHash
      def get(path, params = {})
        @client.send(:request, :get, path, params)
      end
    end
  end
end
