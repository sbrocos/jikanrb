# frozen_string_literal: true

module Jikanrb
  # A Hash that allows access with both Symbol and String keys.
  # This class provides a recursive mechanism to ensure nested Hashes
  # also behave indifferently, similar to ActiveSupport's HashWithIndifferentAccess.
  class IndifferentHash < Hash
    # Initializes a new IndifferentHash.
    #
    # @param hash [Hash] The initial hash to populate the IndifferentHash with.
    def initialize(hash = {})
      super()
      hash.each { |key, value| self[key] = value }
    end

    # Retrieves the value object corresponding to the key object.
    # The key is automatically converted to a string.
    #
    # @param key [Symbol, String] The key to look up.
    # @return [Object] The value associated with the key.
    def [](key)
      super(convert_key(key))
    end

    # Associates the value given by value with the key given by key.
    # The key is automatically converted to a string.
    # The value is processed to ensure nested structures are also indifferent.
    #
    # @param key [Symbol, String] The key to store.
    # @param value [Object] The value to store.
    # @return [Object] The stored value.
    def []=(key, value)
      super(convert_key(key), convert_value(value))
    end

    # Returns a key's value, or the default value if the key is not found.
    # The key is automatically converted to a string.
    #
    # @param key [Symbol, String] The key to look up.
    # @param args [Array] Optional default value or block.
    # @return [Object] The value associated with the key.
    def fetch(key, *args)
      super(convert_key(key), *args)
    end

    # Returns true if the given key is present in the hash.
    # The key is automatically converted to a string.
    #
    # @param key [Symbol, String] The key to check.
    # @return [Boolean] True if the key exists, false otherwise.
    def key?(key)
      super(convert_key(key))
    end

    alias include? key?
    alias has_key? key?
    alias member? key?

    protected

    # Converts the key to a String if it is a Symbol.
    #
    # @param key [Object] The key to convert.
    # @return [String, Object] The converted key.
    def convert_key(key)
      key.is_a?(Symbol) ? key.to_s : key
    end

    # Recursively converts Hash values to IndifferentHash.
    # Also handles Arrays of Hashes.
    #
    # @param value [Object] The value to convert.
    # @return [Object] The converted value.
    def convert_value(value)
      case value
      when Hash
        IndifferentHash.new(value)
      when Array
        value.map { |v| convert_value(v) }
      else
        value
      end
    end
  end
end
