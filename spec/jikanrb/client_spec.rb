# frozen_string_literal: true

RSpec.describe Jikanrb::Client do
  subject(:client) { described_class.new }

  let(:base_url) { 'https://api.jikan.moe' }

  describe '#initialize' do
    it 'creates a new configuration' do
      expect(client.config).to be_a(Jikanrb::Configuration)
    end

    it 'accepts a configuration block' do
      custom_client = described_class.new do |config|
        config.read_timeout = 20
        config.max_retries = 5
      end

      expect(custom_client.config.read_timeout).to eq(20)
      expect(custom_client.config.max_retries).to eq(5)
    end
  end

  describe '#anime' do
    it 'fetches anime by ID' do
      response_body = {
        data: {
          mal_id: 1,
          title: 'Cowboy Bebop',
          type: 'TV'
        }
      }.to_json

      stub_request(:get, "#{base_url}/anime/1")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })

      result = client.anime(1)

      expect(result).to be_a(Jikanrb::IndifferentHash)
      expect(result[:data]).to be_a(Hash)
      expect(result['data']).to eq(result[:data])
      expect(result[:data][:mal_id]).to eq(1)
      expect(result['data']['mal_id']).to eq(1)
      expect(result[:data][:title]).to eq('Cowboy Bebop')
      expect(result['data']['title']).to eq('Cowboy Bebop')
    end

    it 'fetches full anime information' do
      response_body = {
        data: {
          mal_id: 1,
          title: 'Cowboy Bebop',
          relations: []
        }
      }.to_json

      stub_request(:get, "#{base_url}/anime/1/full")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })

      result = client.anime(1, full: true)

      expect(result).to be_a(Hash)
      expect(result['data']).to be_a(Hash)
      expect(result['data']['mal_id']).to eq(1)
      expect(result['data']['relations']).to be_a(Array)
    end
  end

  describe '#manga' do
    it 'fetches manga by ID' do
      response_body = {
        data: {
          mal_id: 1,
          title: 'Monster',
          type: 'Manga'
        }
      }.to_json

      stub_request(:get, "#{base_url}/manga/1")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })

      result = client.manga(1)

      expect(result).to be_a(Hash)
      expect(result['data']).to be_a(Hash)
      expect(result['data']['mal_id']).to eq(1)
      expect(result['data']['title']).to eq('Monster')
    end

    it 'fetches full manga information' do
      response_body = {
        data: {
          mal_id: 1,
          title: 'Monster'
        }
      }.to_json

      stub_request(:get, "#{base_url}/manga/1/full")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })

      result = client.manga(1, full: true)

      expect(result).to be_a(Hash)
      expect(result['data']).to be_a(Hash)
      expect(result['data']['mal_id']).to eq(1)
    end
  end

  describe '#character' do
    it 'fetches character by ID' do
      response_body = {
        data: {
          mal_id: 1,
          name: 'Spike Spiegel'
        }
      }.to_json

      stub_request(:get, "#{base_url}/characters/1")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })

      result = client.character(1)

      expect(result).to be_a(Hash)
      expect(result['data']).to be_a(Hash)
      expect(result['data']['mal_id']).to eq(1)
      expect(result['data']['name']).to eq('Spike Spiegel')
    end

    it 'fetches full character information' do
      response_body = {
        data: {
          mal_id: 1,
          name: 'Spike Spiegel'
        }
      }.to_json

      stub_request(:get, "#{base_url}/characters/1/full")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })

      result = client.character(1, full: true)

      expect(result).to be_a(Hash)
      expect(result['data']).to be_a(Hash)
      expect(result['data']['mal_id']).to eq(1)
    end
  end

  describe '#person' do
    it 'fetches person by ID' do
      response_body = {
        data: {
          mal_id: 1,
          name: 'Rie Kugimiya'
        }
      }.to_json

      stub_request(:get, "#{base_url}/people/1")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })

      result = client.person(1)

      expect(result).to be_a(Hash)
      expect(result['data']).to be_a(Hash)
      expect(result['data']['mal_id']).to eq(1)
    end

    it 'fetches full person information' do
      response_body = {
        data: {
          mal_id: 1,
          name: 'Rie Kugimiya'
        }
      }.to_json

      stub_request(:get, "#{base_url}/people/1/full")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })

      result = client.person(1, full: true)

      expect(result).to be_a(Hash)
      expect(result['data']).to be_a(Hash)
      expect(result['data']['mal_id']).to eq(1)
    end
  end

  describe '#search_anime' do
    it 'searches anime by query' do
      response_body = {
        data: [
          { mal_id: 20, title: 'Naruto' }
        ]
      }.to_json

      stub_request(:get, "#{base_url}/anime?q=Naruto")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })

      result = client.search_anime('Naruto')

      expect(result).to be_a(Hash)
      expect(result['data']).to be_a(Array)
      expect(result['data'].first['title']).to eq('Naruto')
    end

    it 'searches anime with additional parameters' do
      response_body = {
        data: [
          { mal_id: 20, title: 'Naruto', type: 'TV' }
        ]
      }.to_json

      stub_request(:get, "#{base_url}/anime?limit=5&q=Naruto&type=tv")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })

      result = client.search_anime('Naruto', type: 'tv', limit: 5)

      expect(result).to be_a(Hash)
      expect(result['data']).to be_a(Array)
    end
  end

  describe '#search_manga' do
    it 'searches manga by query' do
      response_body = {
        data: [
          { mal_id: 13, title: 'One Piece' }
        ]
      }.to_json

      stub_request(:get, "#{base_url}/manga?q=One%20Piece")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })

      result = client.search_manga('One Piece')

      expect(result).to be_a(Hash)
      expect(result['data']).to be_a(Array)
      expect(result['data'].first['title']).to eq('One Piece')
    end
  end

  describe '#top_anime' do
    it 'fetches top anime' do
      response_body = {
        data: [
          { mal_id: 5114, title: 'Fullmetal Alchemist: Brotherhood' }
        ]
      }.to_json

      stub_request(:get, "#{base_url}/top/anime?page=1")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })

      result = client.top_anime

      expect(result).to be_a(Hash)
      expect(result['data']).to be_a(Array)
      expect(result['data']).not_to be_empty
    end

    it 'fetches top anime with type filter' do
      response_body = {
        data: [
          { mal_id: 5114, title: 'Fullmetal Alchemist: Brotherhood', type: 'TV' }
        ]
      }.to_json

      stub_request(:get, "#{base_url}/top/anime?page=1&type=tv")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })

      result = client.top_anime(type: 'tv')

      expect(result).to be_a(Hash)
      expect(result['data']).to be_a(Array)
    end

    it 'fetches top anime with filter' do
      response_body = {
        data: [
          { mal_id: 5114, title: 'Fullmetal Alchemist: Brotherhood' }
        ]
      }.to_json

      stub_request(:get, "#{base_url}/top/anime?filter=airing&page=1")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })

      result = client.top_anime(filter: 'airing')

      expect(result).to be_a(Hash)
      expect(result['data']).to be_a(Array)
    end
  end

  describe '#top_manga' do
    it 'fetches top manga' do
      response_body = {
        data: [
          { mal_id: 2, title: 'Berserk' }
        ]
      }.to_json

      stub_request(:get, "#{base_url}/top/manga?page=1")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })

      result = client.top_manga

      expect(result).to be_a(Hash)
      expect(result['data']).to be_a(Array)
      expect(result['data']).not_to be_empty
    end
  end

  describe '#season' do
    it 'fetches seasonal anime' do
      response_body = {
        data: [
          { mal_id: 123, title: 'Winter Anime' }
        ]
      }.to_json

      stub_request(:get, "#{base_url}/seasons/2024/winter?page=1")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })

      result = client.season(2024, 'winter')

      expect(result).to be_a(Hash)
      expect(result['data']).to be_a(Array)
    end
  end

  describe '#season_now' do
    it 'fetches current season anime' do
      response_body = {
        data: [
          { mal_id: 456, title: 'Current Season Anime' }
        ]
      }.to_json

      stub_request(:get, "#{base_url}/seasons/now?page=1")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })

      result = client.season_now

      expect(result).to be_a(Hash)
      expect(result['data']).to be_a(Array)
    end
  end

  describe '#schedules' do
    it 'fetches weekly schedule' do
      response_body = {
        data: [
          { mal_id: 789, title: 'Airing Anime' }
        ]
      }.to_json

      stub_request(:get, "#{base_url}/schedules")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })

      result = client.schedules

      expect(result).to be_a(Hash)
      expect(result['data']).to be_a(Array)
    end

    it 'fetches schedule for specific day' do
      response_body = {
        data: [
          { mal_id: 789, title: 'Monday Anime' }
        ]
      }.to_json

      stub_request(:get, "#{base_url}/schedules/monday")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })

      result = client.schedules(day: 'monday')

      expect(result).to be_a(Hash)
      expect(result['data']).to be_a(Array)
    end
  end

  describe 'error handling' do
    context 'when resource is not found' do
      it 'raises NotFoundError' do
        stub_request(:get, "#{base_url}/anime/999999999")
          .to_return(status: 404, body: '', headers: {})

        expect do
          client.anime(999_999_999)
        end.to raise_error(Jikanrb::NotFoundError, /not found/)
      end
    end

    context 'when request is malformed' do
      it 'raises BadRequestError' do
        stub_request(:get, "#{base_url}/anime?invalid_param=bad%20value")
          .to_return(status: 400, body: '', headers: {})

        expect do
          client.get('/anime', { invalid_param: 'bad value' })
        end.to raise_error(Jikanrb::BadRequestError)
      end
    end

    context 'when connection fails' do
      it 'raises ConnectionError' do
        error = Faraday::ConnectionFailed.new('Connection failed')
        allow_any_instance_of(Faraday::Connection).to receive(:get).and_raise(error)

        expect do
          client.anime(1)
        end.to raise_error(Jikanrb::ConnectionError, /Connection failed/)
      end
    end

    context 'when request times out' do
      it 'raises ConnectionError' do
        allow_any_instance_of(Faraday::Connection).to receive(:get).and_raise(Faraday::TimeoutError.new('Timeout'))

        expect do
          client.anime(1)
        end.to raise_error(Jikanrb::ConnectionError, /Connection failed/)
      end
    end

    context 'when response is invalid JSON' do
      it 'raises ParseError' do
        stub_request(:get, "#{base_url}/anime/1")
          .to_return(status: 200, body: 'invalid json{', headers: {})

        expect do
          client.anime(1)
        end.to raise_error(Jikanrb::ParseError, /Failed to parse JSON/)
      end
    end
  end

  describe '#paginate' do
    it 'returns a Paginator instance' do
      paginator = client.paginate(:top_anime)
      expect(paginator).to be_a(Jikanrb::Pagination::Paginator)
    end

    it 'passes parameters to the paginator' do
      paginator = client.paginate(:top_anime, type: 'tv')
      expect(paginator.instance_variable_get(:@params)).to include(type: 'tv')
    end
  end

  describe '#pagination_info' do
    it 'returns a PaginationInfo instance' do
      response = {
        'pagination' => {
          'current_page' => 1,
          'last_visible_page' => 5,
          'has_next_page' => true
        }
      }

      info = client.pagination_info(response)
      expect(info).to be_a(Jikanrb::Pagination::PaginationInfo)
      expect(info.current_page).to eq(1)
      expect(info.total_pages).to eq(5)
    end
  end
end
