# frozen_string_literal: true

module Jikanrb
  # Pagination helper module for paginated API responses
  #
  # @example Iterating through all pages
  #   client = Jikanrb::Client.new
  #   all_anime = client.paginate(:top_anime, type: 'tv')
  #   all_anime.each do |anime|
  #     puts anime['title']
  #   end
  #
  # @example Manual pagination
  #   result = client.top_anime(page: 1)
  #   pagination = Jikanrb::PaginationInfo.new(result)
  #   puts "Page #{pagination.current_page} of #{pagination.total_pages}"
  #   puts "Has next? #{pagination.has_next_page?}"
  module Pagination
    # Represents pagination information from an API response
    class PaginationInfo
      attr_reader :current_page, :last_visible_page, :has_next_page, :items

      # @param response [Hash] API response with pagination data
      def initialize(response)
        @pagination = response['pagination'] || {}
        @current_page = @pagination['current_page'] || 1
        @last_visible_page = @pagination['last_visible_page'] || 1
        @has_next_page = @pagination['has_next_page'] || false
        @items = @pagination['items'] || {}
      end

      # Check if there's a next page
      # @return [Boolean]
      def has_next_page?
        @has_next_page
      end

      # Check if there's a previous page
      # @return [Boolean]
      def has_previous_page?
        @current_page > 1
      end

      # Get next page number
      # @return [Integer, nil] Next page number or nil if no next page
      def next_page
        has_next_page? ? @current_page + 1 : nil
      end

      # Get previous page number
      # @return [Integer, nil] Previous page number or nil if no previous page
      def previous_page
        has_previous_page? ? @current_page - 1 : nil
      end

      # Get total number of pages
      # @return [Integer]
      def total_pages
        @last_visible_page
      end

      # Get number of items per page
      # @return [Integer]
      def per_page
        @items['per_page'] || 25
      end

      # Get total number of items
      # @return [Integer]
      def total_items
        @items['total'] || 0
      end

      # Get current item count
      # @return [Integer]
      def current_item_count
        @items['count'] || 0
      end
    end

    # Paginator class for iterating through all pages
    class Paginator
      include Enumerable

      # @param client [Jikanrb::Client] Client instance
      # @param method [Symbol] Method name to call (e.g., :top_anime)
      # @param params [Hash] Additional parameters for the method
      def initialize(client, method, **params)
        @client = client
        @method = method
        @params = params
        @current_page = params[:page] || 1
      end

      # Iterate through all items across all pages
      # @yield [Hash] Each item from the API response
      def each(&block)
        loop do
          response = @client.public_send(@method, **@params, page: @current_page)
          data = response['data'] || []

          data.each(&block)

          pagination = PaginationInfo.new(response)
          break unless pagination.has_next_page?

          @current_page = pagination.next_page
        end
      end

      # Get all items from all pages as an array
      # @return [Array<Hash>] All items
      def all
        to_a
      end

      # Get items from the first N pages
      # @param page_count [Integer] Number of pages to fetch
      # @return [Array<Hash>] Items from the specified number of pages
      def take_pages(page_count)
        items = []
        page_count.times do
          response = @client.public_send(@method, **@params, page: @current_page)
          data = response['data'] || []

          items.concat(data)

          pagination = PaginationInfo.new(response)
          break unless pagination.has_next_page?

          @current_page = pagination.next_page
        end
        items
      end
    end
  end
end
