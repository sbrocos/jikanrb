# frozen_string_literal: true

RSpec.describe Jikanrb::Pagination do
  describe Jikanrb::Pagination::PaginationInfo do
    let(:response_with_pagination) do
      {
        'data' => [],
        'pagination' => {
          'last_visible_page' => 5,
          'has_next_page' => true,
          'current_page' => 2,
          'items' => {
            'count' => 25,
            'total' => 125,
            'per_page' => 25
          }
        }
      }
    end

    let(:response_last_page) do
      {
        'data' => [],
        'pagination' => {
          'last_visible_page' => 5,
          'has_next_page' => false,
          'current_page' => 5,
          'items' => {
            'count' => 10,
            'total' => 125,
            'per_page' => 25
          }
        }
      }
    end

    let(:response_first_page) do
      {
        'data' => [],
        'pagination' => {
          'last_visible_page' => 5,
          'has_next_page' => true,
          'current_page' => 1,
          'items' => {
            'count' => 25,
            'total' => 125,
            'per_page' => 25
          }
        }
      }
    end

    describe '#initialize' do
      it 'extracts pagination data from response' do
        info = described_class.new(response_with_pagination)

        expect(info.current_page).to eq(2)
        expect(info.last_visible_page).to eq(5)
        expect(info.has_next_page).to be true
      end

      it 'handles missing pagination data' do
        info = described_class.new({ 'data' => [] })

        expect(info.current_page).to eq(1)
        expect(info.last_visible_page).to eq(1)
        expect(info.has_next_page).to be false
      end
    end

    describe '#has_next_page?' do
      it 'returns true when there is a next page' do
        info = described_class.new(response_with_pagination)
        expect(info.has_next_page?).to be true
      end

      it 'returns false when on last page' do
        info = described_class.new(response_last_page)
        expect(info.has_next_page?).to be false
      end
    end

    describe '#has_previous_page?' do
      it 'returns true when not on first page' do
        info = described_class.new(response_with_pagination)
        expect(info.has_previous_page?).to be true
      end

      it 'returns false when on first page' do
        info = described_class.new(response_first_page)
        expect(info.has_previous_page?).to be false
      end
    end

    describe '#next_page' do
      it 'returns next page number when available' do
        info = described_class.new(response_with_pagination)
        expect(info.next_page).to eq(3)
      end

      it 'returns nil when no next page' do
        info = described_class.new(response_last_page)
        expect(info.next_page).to be_nil
      end
    end

    describe '#previous_page' do
      it 'returns previous page number when available' do
        info = described_class.new(response_with_pagination)
        expect(info.previous_page).to eq(1)
      end

      it 'returns nil when on first page' do
        info = described_class.new(response_first_page)
        expect(info.previous_page).to be_nil
      end
    end

    describe '#total_pages' do
      it 'returns the total number of pages' do
        info = described_class.new(response_with_pagination)
        expect(info.total_pages).to eq(5)
      end
    end

    describe '#per_page' do
      it 'returns items per page' do
        info = described_class.new(response_with_pagination)
        expect(info.per_page).to eq(25)
      end

      it 'returns default when not specified' do
        info = described_class.new({ 'data' => [] })
        expect(info.per_page).to eq(25)
      end
    end

    describe '#total_items' do
      it 'returns total item count' do
        info = described_class.new(response_with_pagination)
        expect(info.total_items).to eq(125)
      end
    end

    describe '#current_item_count' do
      it 'returns current page item count' do
        info = described_class.new(response_with_pagination)
        expect(info.current_item_count).to eq(25)
      end
    end
  end

  describe Jikanrb::Pagination::Paginator do
    let(:client) { Jikanrb::Client.new }

    let(:page1_response) do
      {
        'data' => [
          { 'mal_id' => 1, 'title' => 'Anime 1' },
          { 'mal_id' => 2, 'title' => 'Anime 2' }
        ],
        'pagination' => {
          'last_visible_page' => 3,
          'has_next_page' => true,
          'current_page' => 1,
          'items' => { 'count' => 2, 'total' => 6, 'per_page' => 2 }
        }
      }
    end

    let(:page2_response) do
      {
        'data' => [
          { 'mal_id' => 3, 'title' => 'Anime 3' },
          { 'mal_id' => 4, 'title' => 'Anime 4' }
        ],
        'pagination' => {
          'last_visible_page' => 3,
          'has_next_page' => true,
          'current_page' => 2,
          'items' => { 'count' => 2, 'total' => 6, 'per_page' => 2 }
        }
      }
    end

    let(:page3_response) do
      {
        'data' => [
          { 'mal_id' => 5, 'title' => 'Anime 5' },
          { 'mal_id' => 6, 'title' => 'Anime 6' }
        ],
        'pagination' => {
          'last_visible_page' => 3,
          'has_next_page' => false,
          'current_page' => 3,
          'items' => { 'count' => 2, 'total' => 6, 'per_page' => 2 }
        }
      }
    end

    before do
      stub_request(:get, 'https://api.jikan.moe/v4/top/anime?page=1')
        .to_return(status: 200, body: page1_response.to_json, headers: { 'Content-Type' => 'application/json' })

      stub_request(:get, 'https://api.jikan.moe/v4/top/anime?page=2')
        .to_return(status: 200, body: page2_response.to_json, headers: { 'Content-Type' => 'application/json' })

      stub_request(:get, 'https://api.jikan.moe/v4/top/anime?page=3')
        .to_return(status: 200, body: page3_response.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    describe '#each' do
      it 'iterates through all items across pages' do
        paginator = described_class.new(client, :top_anime)
        items = paginator.map { |item| item }

        expect(items.length).to eq(6)
        expect(items.map { |i| i['mal_id'] }).to eq([1, 2, 3, 4, 5, 6])
      end

      it 'stops at the last page' do
        paginator = described_class.new(client, :top_anime)

        expect(client).to receive(:top_anime).exactly(3).times.and_call_original

        count = 0
        paginator.each { |_item| count += 1 }
        expect(count).to eq(6) # 3 pages with 2 items each
      end
    end

    describe '#all' do
      it 'returns all items as an array' do
        paginator = described_class.new(client, :top_anime)
        items = paginator.all

        expect(items).to be_an(Array)
        expect(items.length).to eq(6)
        expect(items.first['title']).to eq('Anime 1')
        expect(items.last['title']).to eq('Anime 6')
      end
    end

    describe '#take_pages' do
      it 'fetches items from specified number of pages' do
        paginator = described_class.new(client, :top_anime)
        items = paginator.take_pages(2)

        expect(items.length).to eq(4)
        expect(items.map { |i| i['mal_id'] }).to eq([1, 2, 3, 4])
      end

      it 'stops early if no more pages' do
        paginator = described_class.new(client, :top_anime)
        items = paginator.take_pages(10)

        expect(items.length).to eq(6)
      end
    end
  end
end
