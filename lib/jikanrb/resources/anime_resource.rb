# frozen_string_literal: true

module Jikanrb
  module Resources
    # Resource class for accessing Anime sub-resources from the Jikan API.
    # Provides fluent API access to anime details, characters, staff, episodes,
    # news, forum topics, videos, pictures, statistics, and more.
    #
    # @example Basic usage
    #   client = Jikanrb::Client.new
    #   anime = client.anime(1)
    #   anime.info                   # GET /anime/1
    #   anime.info(full: true)       # GET /anime/1/full
    #   anime.characters             # GET /anime/1/characters
    #   anime.episodes               # GET /anime/1/episodes
    #
    # @see https://docs.api.jikan.moe/#tag/anime
    class AnimeResource < BaseResource
      # Returns anime details
      #
      # @param full [Boolean] If true, returns extended information including
      #   relations, themes, external links, and streaming links
      # @return [Hash] Anime data as IndifferentHash
      #
      # @example Get basic info
      #   client.anime(1).info
      #   # => { data: { mal_id: 1, title: "Cowboy Bebop", ... } }
      #
      # @example Get full info
      #   client.anime(1).info(full: true)
      #   # => { data: { mal_id: 1, title: "...", relations: [...], themes: {...} } }
      def info(full: false)
        path = full ? "anime/#{@id}/full" : "anime/#{@id}"
        get(path)
      end

      # Returns characters and their voice actors for this anime
      #
      # @return [Hash] List of characters as IndifferentHash
      #
      # @example
      #   client.anime(1).characters
      #   # => { data: [{ character: { mal_id: 1, name: "Spike Spiegel" }, role: "Main", voice_actors: [...] }, ...] }
      def characters
        get("anime/#{@id}/characters")
      end

      # Returns staff members for this anime
      #
      # @return [Hash] List of staff as IndifferentHash
      #
      # @example
      #   client.anime(1).staff
      #   # => { data: [{ person: { mal_id: 1, name: "..." }, positions: ["Director"] }, ...] }
      def staff
        get("anime/#{@id}/staff")
      end

      # Returns episodes for this anime
      #
      # @param page [Integer, nil] Page number for pagination
      # @return [Hash] List of episodes as IndifferentHash
      #
      # @example Get first page of episodes
      #   client.anime(1).episodes
      #   # => { data: [{ mal_id: 1, title: "Asteroid Blues", ... }, ...], pagination: { ... } }
      #
      # @example Get specific page
      #   client.anime(1).episodes(page: 2)
      def episodes(page: nil)
        get("anime/#{@id}/episodes", { page: page }.compact)
      end

      # Returns news articles related to this anime
      #
      # @return [Hash] List of news articles as IndifferentHash
      #
      # @example
      #   client.anime(1).news
      #   # => { data: [{ mal_id: 1, title: "...", date: "...", author_username: "..." }, ...] }
      def news
        get("anime/#{@id}/news")
      end

      # Returns forum topics related to this anime
      #
      # @return [Hash] List of forum topics as IndifferentHash
      #
      # @example
      #   client.anime(1).forum
      #   # => { data: [{ mal_id: 1, title: "...", date: "...", author_username: "..." }, ...] }
      def forum
        get("anime/#{@id}/forum")
      end

      # Returns videos (PVs, episodes, music videos) for this anime
      #
      # @return [Hash] Video data as IndifferentHash
      #
      # @example
      #   client.anime(1).videos
      #   # => { data: { promo: [...], episodes: [...], music_videos: [...] } }
      def videos
        get("anime/#{@id}/videos")
      end

      # Returns pictures of this anime
      #
      # @return [Hash] List of pictures as IndifferentHash
      #
      # @example
      #   client.anime(1).pictures
      #   # => { data: [{ jpg: { image_url: "https://..." }, webp: { ... } }, ...] }
      def pictures
        get("anime/#{@id}/pictures")
      end

      # Returns statistics for this anime
      #
      # @return [Hash] Statistics data as IndifferentHash
      #
      # @example
      #   client.anime(1).statistics
      #   # => { data: { watching: 12345, completed: 67890, on_hold: 1234, ... } }
      def statistics
        get("anime/#{@id}/statistics")
      end

      # Returns user recommendations for this anime
      #
      # @return [Hash] List of recommendations as IndifferentHash
      #
      # @example
      #   client.anime(1).recommendations
      #   # => { data: [{ entry: { mal_id: 5, title: "..." }, votes: 123 }, ...] }
      def recommendations
        get("anime/#{@id}/recommendations")
      end

      # Returns related anime/manga entries
      #
      # @return [Hash] List of relations as IndifferentHash
      #
      # @example
      #   client.anime(1).relations
      #   # => { data: [{ relation: "Adaptation", entry: [{ mal_id: 173, type: "manga", name: "..." }] }, ...] }
      def relations
        get("anime/#{@id}/relations")
      end

      # Returns opening and ending themes for this anime
      #
      # @return [Hash] Theme songs as IndifferentHash
      #
      # @example
      #   client.anime(1).themes
      #   # => { data: { openings: ["Tank! by The Seatbelts"], endings: ["The Real Folk Blues by ..."] } }
      def themes
        get("anime/#{@id}/themes")
      end

      # Returns external links for this anime
      #
      # @return [Hash] List of external links as IndifferentHash
      #
      # @example
      #   client.anime(1).external
      #   # => { data: [{ name: "Official Site", url: "https://..." }, ...] }
      def external
        get("anime/#{@id}/external")
      end

      # Returns streaming links for this anime
      #
      # @return [Hash] List of streaming platforms as IndifferentHash
      #
      # @example
      #   client.anime(1).streaming
      #   # => { data: [{ name: "Crunchyroll", url: "https://..." }, ...] }
      def streaming
        get("anime/#{@id}/streaming")
      end
    end
  end
end
