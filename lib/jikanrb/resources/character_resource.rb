# frozen_string_literal: true

module Jikanrb
  module Resources
    # Resource class for accessing Character sub-resources from the Jikan API.
    # Provides fluent API access to character details, anime appearances,
    # manga appearances, voice actors, and pictures.
    #
    # @example Basic usage
    #   client = Jikanrb::Client.new
    #   character = client.character(1)
    #   character.info                  # GET /characters/1
    #   character.info(full: true)      # GET /characters/1/full
    #   character.anime                 # GET /characters/1/anime
    #   character.voices                # GET /characters/1/voices
    #
    # @see https://docs.api.jikan.moe/#tag/characters
    class CharacterResource < BaseResource
      # Returns character details
      #
      # @param full [Boolean] If true, returns extended information including
      #   anime appearances, manga appearances, and voice actors
      # @return [Hash] Character data as IndifferentHash
      #
      # @example Get basic info
      #   client.character(1).info
      #   # => { data: { mal_id: 1, name: "Spike Spiegel", ... } }
      #
      # @example Get full info
      #   client.character(1).info(full: true)
      #   # => { data: { mal_id: 1, name: "...", anime: [...], voices: [...] } }
      def info(full: false)
        path = full ? "characters/#{@id}/full" : "characters/#{@id}"
        get(path)
      end

      # Returns anime appearances for this character
      #
      # @return [Hash] List of anime appearances as IndifferentHash
      #
      # @example
      #   client.character(1).anime
      #   # => { data: [{ role: "Main", anime: { mal_id: 1, title: "..." } }, ...] }
      def animes
        get("characters/#{@id}/anime")
      end

      # Returns manga appearances for this character
      #
      # @return [Hash] List of manga appearances as IndifferentHash
      #
      # @example
      #   client.character(1).manga
      #   # => { data: [{ role: "Main", manga: { mal_id: 1, title: "..." } }, ...] }
      def mangas
        get("characters/#{@id}/manga")
      end

      # Returns voice actors for this character
      #
      # @return [Hash] List of voice actors as IndifferentHash
      #
      # @example
      #   client.character(1).voices
      #   # => { data: [{ language: "Japanese", person: { mal_id: 11, name: "..." } }, ...] }
      def voices
        get("characters/#{@id}/voices")
      end

      # Returns pictures of this character
      #
      # @return [Hash] List of pictures as IndifferentHash
      #
      # @example
      #   client.character(1).pictures
      #   # => { data: [{ jpg: { image_url: "https://..." } }, ...] }
      def pictures
        get("characters/#{@id}/pictures")
      end
    end
  end
end
