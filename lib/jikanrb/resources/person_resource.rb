# frozen_string_literal: true

module Jikanrb
  module Resources
    # Resource class for accessing Person sub-resources from the Jikan API.
    # Provides fluent API access to person details, anime staff positions,
    # manga work, voice acting roles, and pictures.
    #
    # @example Basic usage
    #   client = Jikanrb::Client.new
    #   person = client.person(1)
    #   person.info                  # GET /people/1
    #   person.info(full: true)      # GET /people/1/full
    #   person.animes                # GET /people/1/anime
    #   person.voices                # GET /people/1/voices
    #
    # @see https://docs.api.jikan.moe/#tag/people
    class PersonResource < BaseResource
      # Returns person details
      #
      # @param full [Boolean] If true, returns extended information including
      #   anime, manga, and voice acting roles
      # @return [Hash] Person data as IndifferentHash
      #
      # @example Get basic info
      #   client.person(1).info
      #   # => { data: { mal_id: 1, name: "Tomokazu Seki", ... } }
      #
      # @example Get full info
      #   client.person(1).info(full: true)
      #   # => { data: { mal_id: 1, name: "...", anime: [...], voices: [...] } }
      def info(full: false)
        path = full ? "people/#{@id}/full" : "people/#{@id}"
        get(path)
      end

      # Returns anime staff positions for this person
      #
      # @return [Hash] List of anime staff positions as IndifferentHash
      #
      # @example
      #   client.person(1).animes
      #   # => { data: [{ position: "Director", anime: { mal_id: 1, title: "..." } }, ...] }
      def animes
        get("people/#{@id}/anime")
      end

      # Returns manga work positions for this person
      #
      # @return [Hash] List of manga work positions as IndifferentHash
      #
      # @example
      #   client.person(1).mangas
      #   # => { data: [{ position: "Story & Art", manga: { mal_id: 1, title: "..." } }, ...] }
      def mangas
        get("people/#{@id}/manga")
      end

      # Returns voice acting roles for this person
      #
      # @return [Hash] List of voice acting roles as IndifferentHash
      #
      # @example
      #   client.person(1).voices
      #   # => { data: [{ role: "Main", character: { ... }, anime: { ... } }, ...] }
      def voices
        get("people/#{@id}/voices")
      end

      # Returns pictures of this person
      #
      # @return [Hash] List of pictures as IndifferentHash
      #
      # @example
      #   client.person(1).pictures
      #   # => { data: [{ jpg: { image_url: "https://..." } }, ...] }
      def pictures
        get("people/#{@id}/pictures")
      end
    end
  end
end
