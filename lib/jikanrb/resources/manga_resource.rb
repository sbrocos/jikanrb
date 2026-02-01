# frozen_string_literal: true

module Jikanrb
  module Resources
    # Resource class for accessing Manga sub-resources from the Jikan API.
    # Provides fluent API access to manga details, characters, news,
    # forum topics, pictures, statistics, and more.
    #
    # @example Basic usage
    #   client = Jikanrb::Client.new
    #   manga = client.manga(1)
    #   manga.info                   # GET /manga/1
    #   manga.info(full: true)       # GET /manga/1/full
    #   manga.characters             # GET /manga/1/characters
    #
    # @see https://docs.api.jikan.moe/#tag/manga
    class MangaResource < BaseResource
      # Returns manga details
      #
      # @param full [Boolean] If true, returns extended information including
      #   relations, external links, etc.
      # @return [Hash] Manga data as IndifferentHash
      #
      # @example Get basic info
      #   client.manga(1).info
      #   # => { data: { mal_id: 1, title: "Monster", ... } }
      #
      # @example Get full info
      #   client.manga(1).info(full: true)
      #   # => { data: { mal_id: 1, title: "...", relations: [...], external: [...] } }
      def info(full: false)
        path = full ? "manga/#{@id}/full" : "manga/#{@id}"
        get(path)
      end

      # Returns characters for this manga
      #
      # @return [Hash] List of characters as IndifferentHash
      #
      # @example
      #   client.manga(1).characters
      #   # => { data: [{ character: { mal_id: 1, name: "Kenzou Tenma" }, role: "Main" }, ...] }
      def characters
        get("manga/#{@id}/characters")
      end

      # Returns news articles related to this manga
      #
      # @return [Hash] List of news articles as IndifferentHash
      #
      # @example
      #   client.manga(1).news
      #   # => { data: [{ mal_id: 1, title: "...", date: "...", author_username: "..." }, ...] }
      def news
        get("manga/#{@id}/news")
      end

      # Returns forum topics related to this manga
      #
      # @return [Hash] List of forum topics as IndifferentHash
      #
      # @example
      #   client.manga(1).forum
      #   # => { data: [{ mal_id: 1, title: "...", date: "...", author_username: "..." }, ...] }
      def forum
        get("manga/#{@id}/forum")
      end

      # Returns pictures of this manga
      #
      # @return [Hash] List of pictures as IndifferentHash
      #
      # @example
      #   client.manga(1).pictures
      #   # => { data: [{ jpg: { image_url: "https://..." }, webp: { ... } }, ...] }
      def pictures
        get("manga/#{@id}/pictures")
      end

      # Returns statistics for this manga
      #
      # @return [Hash] Statistics data as IndifferentHash
      #
      # @example
      #   client.manga(1).statistics
      #   # => { data: { reading: 12345, completed: 67890, on_hold: 1234, ... } }
      def statistics
        get("manga/#{@id}/statistics")
      end

      # Returns user recommendations for this manga
      #
      # @return [Hash] List of recommendations as IndifferentHash
      #
      # @example
      #   client.manga(1).recommendations
      #   # => { data: [{ entry: { mal_id: 5, title: "..." }, votes: 123 }, ...] }
      def recommendations
        get("manga/#{@id}/recommendations")
      end

      # Returns related anime/manga entries
      #
      # @return [Hash] List of relations as IndifferentHash
      #
      # @example
      #   client.manga(1).relations
      #   # => { data: [{ relation: "Adaptation", entry: [{ mal_id: 19, type: "anime", name: "..." }] }, ...] }
      def relations
        get("manga/#{@id}/relations")
      end

      # Returns external links for this manga
      #
      # @return [Hash] List of external links as IndifferentHash
      #
      # @example
      #   client.manga(1).external
      #   # => { data: [{ name: "Official Site", url: "https://..." }, ...] }
      def external
        get("manga/#{@id}/external")
      end
    end
  end
end
