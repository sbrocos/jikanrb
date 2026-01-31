# frozen_string_literal: true

RSpec.describe Jikanrb::Resources::MangaResource do
  subject(:resource) { described_class.new(client, manga_id) }

  let(:client) { Jikanrb::Client.new }
  let(:manga_id) { 1 }
  let(:base_url) { 'https://api.jikan.moe/v4' }

  describe '#initialize' do
    it 'stores the client reference' do
      expect(resource.instance_variable_get(:@client)).to eq(client)
    end

    it 'stores the manga ID' do
      expect(resource.instance_variable_get(:@id)).to eq(manga_id)
    end
  end

  describe '#info' do
    context 'when fetching basic info' do
      let(:response_body) do
        {
          data: {
            mal_id: 1,
            title: 'Monster',
            title_japanese: 'MONSTER',
            chapters: 162,
            volumes: 18
          }
        }.to_json
      end

      before do
        stub_request(:get, "#{base_url}/manga/#{manga_id}")
          .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns manga details as hash' do
        expect(resource.info).to be_a(Hash)
      end

      it 'returns correct mal_id with symbol access' do
        expect(resource.info[:data][:mal_id]).to eq(1)
      end

      it 'returns correct title with string access' do
        expect(resource.info['data']['title']).to eq('Monster')
      end
    end

    context 'when fetching full info' do
      let(:response_body) do
        {
          data: {
            mal_id: 1,
            title: 'Monster',
            relations: [],
            external: []
          }
        }.to_json
      end

      before do
        stub_request(:get, "#{base_url}/manga/#{manga_id}/full")
          .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns extended manga details' do
        result = resource.info(full: true)

        expect(result[:data][:mal_id]).to eq(1)
        expect(result[:data][:relations]).to be_a(Array)
        expect(result[:data][:external]).to be_a(Array)
      end
    end
  end

  describe '#characters' do
    let(:response_body) do
      {
        data: [
          { character: { mal_id: 1, name: 'Kenzou Tenma' }, role: 'Main' },
          { character: { mal_id: 2, name: 'Johan Liebert' }, role: 'Main' }
        ]
      }.to_json
    end

    before do
      stub_request(:get, "#{base_url}/manga/#{manga_id}/characters")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns manga characters as array' do
      result = resource.characters

      expect(result[:data]).to be_a(Array)
      expect(result[:data].length).to eq(2)
      expect(result[:data].first[:role]).to eq('Main')
    end

    it 'supports string access for character data' do
      expect(resource.characters['data'].first['character']['name']).to eq('Kenzou Tenma')
    end
  end

  describe '#news' do
    let(:response_body) do
      {
        data: [
          { mal_id: 12_345, title: 'Monster Live-Action Adaptation Announced', date: '2023-06-15' }
        ]
      }.to_json
    end

    before do
      stub_request(:get, "#{base_url}/manga/#{manga_id}/news")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns manga news as array' do
      result = resource.news

      expect(result[:data]).to be_a(Array)
      expect(result[:data].first[:title]).to eq('Monster Live-Action Adaptation Announced')
    end
  end

  describe '#forum' do
    let(:response_body) do
      {
        data: [
          { mal_id: 1234, title: 'Best manga ever discussion', comments: 156 }
        ]
      }.to_json
    end

    before do
      stub_request(:get, "#{base_url}/manga/#{manga_id}/forum")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns manga forum topics as array' do
      result = resource.forum

      expect(result[:data]).to be_a(Array)
      expect(result[:data].first[:title]).to eq('Best manga ever discussion')
    end
  end

  describe '#pictures' do
    let(:response_body) do
      {
        data: [
          { jpg: { image_url: 'https://cdn.myanimelist.net/images/manga/3/54525.jpg' } },
          { jpg: { image_url: 'https://cdn.myanimelist.net/images/manga/3/54526.jpg' } }
        ]
      }.to_json
    end

    before do
      stub_request(:get, "#{base_url}/manga/#{manga_id}/pictures")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns manga pictures' do
      result = resource.pictures

      expect(result[:data]).to be_a(Array)
      expect(result[:data].length).to eq(2)
      expect(result[:data].first[:jpg][:image_url]).to include('myanimelist.net')
    end
  end

  describe '#statistics' do
    let(:response_body) do
      {
        data: {
          reading: 50_000,
          completed: 300_000,
          on_hold: 25_000,
          dropped: 10_000,
          plan_to_read: 100_000,
          total: 485_000,
          scores: [{ score: 10, votes: 50_000, percentage: 25.5 }]
        }
      }.to_json
    end

    before do
      stub_request(:get, "#{base_url}/manga/#{manga_id}/statistics")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns manga statistics' do
      result = resource.statistics

      expect(result[:data][:reading]).to eq(50_000)
      expect(result[:data][:completed]).to eq(300_000)
      expect(result[:data][:total]).to eq(485_000)
    end

    it 'includes score distribution' do
      result = resource.statistics

      expect(result[:data][:scores]).to be_a(Array)
      expect(result[:data][:scores].first[:score]).to eq(10)
    end
  end

  describe '#recommendations' do
    let(:response_body) do
      {
        data: [
          { entry: { mal_id: 2, title: 'Berserk' }, votes: 150 },
          { entry: { mal_id: 3, title: '20th Century Boys' }, votes: 120 }
        ]
      }.to_json
    end

    before do
      stub_request(:get, "#{base_url}/manga/#{manga_id}/recommendations")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns manga recommendations as array' do
      result = resource.recommendations

      expect(result[:data]).to be_a(Array)
      expect(result[:data].length).to eq(2)
      expect(result[:data].first[:votes]).to eq(150)
    end

    it 'includes recommended entry details' do
      result = resource.recommendations

      expect(result[:data].first[:entry][:title]).to eq('Berserk')
    end
  end

  describe '#relations' do
    let(:response_body) do
      {
        data: [
          { relation: 'Adaptation', entry: [{ mal_id: 19, name: 'Monster' }] },
          { relation: 'Side story', entry: [{ mal_id: 1094, name: 'Another Monster' }] }
        ]
      }.to_json
    end

    before do
      stub_request(:get, "#{base_url}/manga/#{manga_id}/relations")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns manga relations as array' do
      result = resource.relations

      expect(result[:data]).to be_a(Array)
      expect(result[:data].first[:relation]).to eq('Adaptation')
    end

    it 'includes related entries' do
      result = resource.relations

      expect(result[:data].first[:entry]).to be_a(Array)
      expect(result[:data].first[:entry].first[:name]).to eq('Monster')
    end
  end

  describe '#external' do
    let(:response_body) do
      {
        data: [
          { name: 'Official Site', url: 'http://monster.viz.com/' },
          { name: 'Wikipedia', url: 'https://en.wikipedia.org/wiki/Monster_(manga)' }
        ]
      }.to_json
    end

    before do
      stub_request(:get, "#{base_url}/manga/#{manga_id}/external")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns external links as array' do
      result = resource.external

      expect(result[:data]).to be_a(Array)
      expect(result[:data].length).to eq(2)
      expect(result[:data].first[:name]).to eq('Official Site')
    end
  end

  describe 'Client#manga fluent API integration' do
    describe '#manga' do
      it 'returns a MangaResource instance' do
        expect(client.manga(1)).to be_a(described_class)
      end

      it 'passes the correct ID to the resource' do
        expect(client.manga(123).instance_variable_get(:@id)).to eq(123)
      end

      it 'passes the client reference to the resource' do
        expect(client.manga(1).instance_variable_get(:@client)).to eq(client)
      end
    end

    describe 'fluent chaining' do
      it 'allows chaining .manga(id).info' do
        stub_request(:get, "#{base_url}/manga/1")
          .to_return(status: 200, body: { data: { mal_id: 1, title: 'Monster' } }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.manga(1).info[:data][:title]).to eq('Monster')
      end

      it 'allows chaining .manga(id).info(full: true)' do
        stub_request(:get, "#{base_url}/manga/1/full")
          .to_return(status: 200, body: { data: { mal_id: 1, title: 'Monster', relations: [] } }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.manga(1).info(full: true)[:data][:relations]).to be_a(Array)
      end

      it 'allows chaining .manga(id).characters' do
        stub_request(:get, "#{base_url}/manga/1/characters")
          .to_return(status: 200, body: { data: [{ role: 'Main', character: { mal_id: 1 } }] }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.manga(1).characters[:data]).to be_a(Array)
      end

      it 'allows chaining .manga(id).news' do
        stub_request(:get, "#{base_url}/manga/1/news")
          .to_return(status: 200, body: { data: [{ title: 'News title' }] }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.manga(1).news[:data]).to be_a(Array)
      end

      it 'allows chaining .manga(id).forum' do
        stub_request(:get, "#{base_url}/manga/1/forum")
          .to_return(status: 200, body: { data: [{ title: 'Forum topic' }] }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.manga(1).forum[:data]).to be_a(Array)
      end

      it 'allows chaining .manga(id).pictures' do
        stub_request(:get, "#{base_url}/manga/1/pictures")
          .to_return(status: 200, body: { data: [{ jpg: { image_url: 'https://example.com/pic.jpg' } }] }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.manga(1).pictures[:data]).to be_a(Array)
      end

      it 'allows chaining .manga(id).statistics' do
        stub_request(:get, "#{base_url}/manga/1/statistics")
          .to_return(status: 200, body: { data: { reading: 1000, completed: 5000 } }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.manga(1).statistics[:data][:reading]).to eq(1000)
      end

      it 'allows chaining .manga(id).recommendations' do
        stub_request(:get, "#{base_url}/manga/1/recommendations")
          .to_return(status: 200, body: { data: [{ entry: { mal_id: 5 }, votes: 10 }] }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.manga(1).recommendations[:data]).to be_a(Array)
      end

      it 'allows chaining .manga(id).relations' do
        stub_request(:get, "#{base_url}/manga/1/relations")
          .to_return(status: 200, body: { data: [{ relation: 'Adaptation', entry: [] }] }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.manga(1).relations[:data]).to be_a(Array)
      end

      it 'allows chaining .manga(id).external' do
        stub_request(:get, "#{base_url}/manga/1/external")
          .to_return(status: 200, body: { data: [{ name: 'Site', url: 'https://example.com' }] }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.manga(1).external[:data]).to be_a(Array)
      end
    end
  end
end
