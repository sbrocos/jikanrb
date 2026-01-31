# frozen_string_literal: true

RSpec.describe Jikanrb::Resources::AnimeResource do
  subject(:resource) { described_class.new(client, anime_id) }

  let(:client) { Jikanrb::Client.new }
  let(:anime_id) { 1 }
  let(:base_url) { 'https://api.jikan.moe/v4' }

  describe '#initialize' do
    it 'stores the client reference' do
      expect(resource.instance_variable_get(:@client)).to eq(client)
    end

    it 'stores the anime ID' do
      expect(resource.instance_variable_get(:@id)).to eq(anime_id)
    end
  end

  describe '#info' do
    context 'when fetching basic info' do
      let(:response_body) do
        {
          data: {
            mal_id: 1,
            title: 'Cowboy Bebop',
            title_japanese: 'カウボーイビバップ',
            episodes: 26
          }
        }.to_json
      end

      before do
        stub_request(:get, "#{base_url}/anime/#{anime_id}")
          .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns anime details as hash' do
        expect(resource.info).to be_a(Hash)
      end

      it 'returns correct mal_id with symbol access' do
        expect(resource.info[:data][:mal_id]).to eq(1)
      end

      it 'returns correct title with string access' do
        expect(resource.info['data']['title']).to eq('Cowboy Bebop')
      end
    end

    context 'when fetching full info' do
      let(:response_body) do
        {
          data: {
            mal_id: 1,
            title: 'Cowboy Bebop',
            relations: [],
            theme: { openings: [], endings: [] },
            external: [],
            streaming: []
          }
        }.to_json
      end

      before do
        stub_request(:get, "#{base_url}/anime/#{anime_id}/full")
          .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns extended anime details' do
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
          { character: { mal_id: 1, name: 'Spike Spiegel' }, role: 'Main' },
          { character: { mal_id: 2, name: 'Faye Valentine' }, role: 'Main' }
        ]
      }.to_json
    end

    before do
      stub_request(:get, "#{base_url}/anime/#{anime_id}/characters")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns anime characters as array' do
      result = resource.characters

      expect(result[:data]).to be_a(Array)
      expect(result[:data].length).to eq(2)
      expect(result[:data].first[:role]).to eq('Main')
    end

    it 'supports string access for character data' do
      expect(resource.characters['data'].first['character']['name']).to eq('Spike Spiegel')
    end
  end

  describe '#staff' do
    let(:response_body) do
      {
        data: [
          { person: { mal_id: 40_135, name: 'Shinichiro Watanabe' }, positions: ['Director'] },
          { person: { mal_id: 508, name: 'Yoko Kanno' }, positions: ['Music'] }
        ]
      }.to_json
    end

    before do
      stub_request(:get, "#{base_url}/anime/#{anime_id}/staff")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns anime staff as array' do
      result = resource.staff

      expect(result[:data]).to be_a(Array)
      expect(result[:data].length).to eq(2)
      expect(result[:data].first[:positions]).to include('Director')
    end

    it 'supports string access for staff data' do
      expect(resource.staff['data'].first['person']['name']).to eq('Shinichiro Watanabe')
    end
  end

  describe '#episodes' do
    let(:response_body) do
      {
        data: [
          { mal_id: 1, title: 'Asteroid Blues', aired: '1998-10-24' },
          { mal_id: 2, title: 'Stray Dog Strut', aired: '1998-04-03' }
        ],
        pagination: { last_visible_page: 2, has_next_page: true }
      }.to_json
    end

    before do
      stub_request(:get, "#{base_url}/anime/#{anime_id}/episodes")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns anime episodes as array' do
      result = resource.episodes

      expect(result[:data]).to be_a(Array)
      expect(result[:data].first[:title]).to eq('Asteroid Blues')
    end

    it 'includes pagination information' do
      result = resource.episodes

      expect(result[:pagination][:has_next_page]).to be(true)
    end

    context 'with page parameter' do
      before do
        stub_request(:get, "#{base_url}/anime/#{anime_id}/episodes")
          .with(query: { page: 2 })
          .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'passes page parameter to API' do
        resource.episodes(page: 2)

        expect(WebMock).to have_requested(:get, "#{base_url}/anime/#{anime_id}/episodes")
          .with(query: { page: 2 })
      end
    end
  end

  describe '#news' do
    let(:response_body) do
      {
        data: [
          { mal_id: 12_345, title: 'Cowboy Bebop Anniversary', date: '2023-04-03' }
        ]
      }.to_json
    end

    before do
      stub_request(:get, "#{base_url}/anime/#{anime_id}/news")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns anime news as array' do
      result = resource.news

      expect(result[:data]).to be_a(Array)
      expect(result[:data].first[:title]).to eq('Cowboy Bebop Anniversary')
    end
  end

  describe '#forum' do
    let(:response_body) do
      {
        data: [
          { mal_id: 1234, title: 'Best episodes discussion', comments: 42 }
        ]
      }.to_json
    end

    before do
      stub_request(:get, "#{base_url}/anime/#{anime_id}/forum")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns anime forum topics as array' do
      result = resource.forum

      expect(result[:data]).to be_a(Array)
      expect(result[:data].first[:title]).to eq('Best episodes discussion')
    end
  end

  describe '#videos' do
    let(:response_body) do
      {
        data: {
          promo: [{ title: 'PV 1', trailer: { youtube_id: 'abc123' } }],
          episodes: [{ mal_id: 1, title: 'Episode 1', episode: '1' }]
        }
      }.to_json
    end

    before do
      stub_request(:get, "#{base_url}/anime/#{anime_id}/videos")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns anime videos' do
      result = resource.videos

      expect(result[:data][:promo]).to be_a(Array)
      expect(result[:data][:promo].first[:title]).to eq('PV 1')
    end

    it 'includes episodes videos' do
      result = resource.videos

      expect(result[:data][:episodes]).to be_a(Array)
    end
  end

  describe '#pictures' do
    let(:response_body) do
      {
        data: [
          { jpg: { image_url: 'https://cdn.myanimelist.net/images/anime/4/19644.jpg' } },
          { jpg: { image_url: 'https://cdn.myanimelist.net/images/anime/4/19645.jpg' } }
        ]
      }.to_json
    end

    before do
      stub_request(:get, "#{base_url}/anime/#{anime_id}/pictures")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns anime pictures' do
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
          watching: 150_000,
          completed: 800_000,
          on_hold: 50_000,
          dropped: 20_000,
          plan_to_watch: 200_000,
          total: 1_220_000,
          scores: [{ score: 10, votes: 100_000, percentage: 30.5 }]
        }
      }.to_json
    end

    before do
      stub_request(:get, "#{base_url}/anime/#{anime_id}/statistics")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns anime statistics' do
      result = resource.statistics

      expect(result[:data][:watching]).to eq(150_000)
      expect(result[:data][:completed]).to eq(800_000)
      expect(result[:data][:total]).to eq(1_220_000)
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
          { entry: { mal_id: 5, title: 'Cowboy Bebop: Tengoku no Tobira' }, votes: 100 },
          { entry: { mal_id: 205, title: 'Samurai Champloo' }, votes: 85 }
        ]
      }.to_json
    end

    before do
      stub_request(:get, "#{base_url}/anime/#{anime_id}/recommendations")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns anime recommendations as array' do
      result = resource.recommendations

      expect(result[:data]).to be_a(Array)
      expect(result[:data].length).to eq(2)
      expect(result[:data].first[:votes]).to eq(100)
    end

    it 'includes recommended entry details' do
      result = resource.recommendations

      expect(result[:data].first[:entry][:title]).to eq('Cowboy Bebop: Tengoku no Tobira')
    end
  end

  describe '#relations' do
    let(:response_body) do
      {
        data: [
          { relation: 'Sequel', entry: [{ mal_id: 5, name: 'Cowboy Bebop: Tengoku no Tobira' }] },
          { relation: 'Side story', entry: [{ mal_id: 17_205, name: 'Cowboy Bebop: Ein no Natsuyasumi' }] }
        ]
      }.to_json
    end

    before do
      stub_request(:get, "#{base_url}/anime/#{anime_id}/relations")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns anime relations as array' do
      result = resource.relations

      expect(result[:data]).to be_a(Array)
      expect(result[:data].first[:relation]).to eq('Sequel')
    end

    it 'includes related entries' do
      result = resource.relations

      expect(result[:data].first[:entry]).to be_a(Array)
      expect(result[:data].first[:entry].first[:name]).to eq('Cowboy Bebop: Tengoku no Tobira')
    end
  end

  describe '#themes' do
    let(:response_body) do
      {
        data: {
          openings: ['Tank! by Seatbelts'],
          endings: ['The Real Folk Blues by Seatbelts']
        }
      }.to_json
    end

    before do
      stub_request(:get, "#{base_url}/anime/#{anime_id}/themes")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns anime themes' do
      result = resource.themes

      expect(result[:data][:openings]).to be_a(Array)
      expect(result[:data][:openings].first).to include('Tank!')
    end

    it 'includes both openings and endings' do
      result = resource.themes

      expect(result[:data][:endings]).to be_a(Array)
      expect(result[:data][:endings].first).to include('Real Folk Blues')
    end
  end

  describe '#external' do
    let(:response_body) do
      {
        data: [
          { name: 'Official Site', url: 'http://www.cowboy-bebop.net/' },
          { name: 'Wikipedia', url: 'https://en.wikipedia.org/wiki/Cowboy_Bebop' }
        ]
      }.to_json
    end

    before do
      stub_request(:get, "#{base_url}/anime/#{anime_id}/external")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns external links as array' do
      result = resource.external

      expect(result[:data]).to be_a(Array)
      expect(result[:data].length).to eq(2)
      expect(result[:data].first[:name]).to eq('Official Site')
    end
  end

  describe '#streaming' do
    let(:response_body) do
      {
        data: [
          { name: 'Crunchyroll', url: 'https://www.crunchyroll.com/cowboy-bebop' },
          { name: 'Funimation', url: 'https://www.funimation.com/shows/cowboy-bebop/' }
        ]
      }.to_json
    end

    before do
      stub_request(:get, "#{base_url}/anime/#{anime_id}/streaming")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns streaming links as array' do
      result = resource.streaming

      expect(result[:data]).to be_a(Array)
      expect(result[:data].length).to eq(2)
      expect(result[:data].first[:name]).to eq('Crunchyroll')
    end
  end

  describe 'Client#anime fluent API integration' do
    describe '#anime' do
      it 'returns an AnimeResource instance' do
        expect(client.anime(1)).to be_a(described_class)
      end

      it 'passes the correct ID to the resource' do
        expect(client.anime(123).instance_variable_get(:@id)).to eq(123)
      end

      it 'passes the client reference to the resource' do
        expect(client.anime(1).instance_variable_get(:@client)).to eq(client)
      end
    end

    describe 'fluent chaining' do
      it 'allows chaining .anime(id).info' do
        stub_request(:get, "#{base_url}/anime/1")
          .to_return(status: 200, body: { data: { mal_id: 1, title: 'Cowboy Bebop' } }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.anime(1).info[:data][:title]).to eq('Cowboy Bebop')
      end

      it 'allows chaining .anime(id).info(full: true)' do
        stub_request(:get, "#{base_url}/anime/1/full")
          .to_return(status: 200, body: { data: { mal_id: 1, title: 'Cowboy Bebop', relations: [] } }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.anime(1).info(full: true)[:data][:relations]).to be_a(Array)
      end

      it 'allows chaining .anime(id).characters' do
        stub_request(:get, "#{base_url}/anime/1/characters")
          .to_return(status: 200, body: { data: [{ role: 'Main', character: { mal_id: 1 } }] }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.anime(1).characters[:data]).to be_a(Array)
      end

      it 'allows chaining .anime(id).staff' do
        stub_request(:get, "#{base_url}/anime/1/staff")
          .to_return(status: 200, body: { data: [{ positions: ['Director'], person: { mal_id: 1 } }] }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.anime(1).staff[:data]).to be_a(Array)
      end

      it 'allows chaining .anime(id).episodes' do
        stub_request(:get, "#{base_url}/anime/1/episodes")
          .to_return(status: 200, body: { data: [{ mal_id: 1, title: 'Episode 1' }] }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.anime(1).episodes[:data]).to be_a(Array)
      end

      it 'allows chaining .anime(id).episodes(page: 2)' do
        stub_request(:get, "#{base_url}/anime/1/episodes")
          .with(query: { page: 2 })
          .to_return(status: 200, body: { data: [{ mal_id: 26, title: 'Episode 26' }] }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.anime(1).episodes(page: 2)[:data]).to be_a(Array)
      end

      it 'allows chaining .anime(id).news' do
        stub_request(:get, "#{base_url}/anime/1/news")
          .to_return(status: 200, body: { data: [{ title: 'News title' }] }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.anime(1).news[:data]).to be_a(Array)
      end

      it 'allows chaining .anime(id).forum' do
        stub_request(:get, "#{base_url}/anime/1/forum")
          .to_return(status: 200, body: { data: [{ title: 'Forum topic' }] }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.anime(1).forum[:data]).to be_a(Array)
      end

      it 'allows chaining .anime(id).videos' do
        stub_request(:get, "#{base_url}/anime/1/videos")
          .to_return(status: 200, body: { data: { promo: [], episodes: [] } }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.anime(1).videos[:data][:promo]).to be_a(Array)
      end

      it 'allows chaining .anime(id).pictures' do
        stub_request(:get, "#{base_url}/anime/1/pictures")
          .to_return(status: 200, body: { data: [{ jpg: { image_url: 'https://example.com/pic.jpg' } }] }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.anime(1).pictures[:data]).to be_a(Array)
      end

      it 'allows chaining .anime(id).statistics' do
        stub_request(:get, "#{base_url}/anime/1/statistics")
          .to_return(status: 200, body: { data: { watching: 1000, completed: 5000 } }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.anime(1).statistics[:data][:watching]).to eq(1000)
      end

      it 'allows chaining .anime(id).recommendations' do
        stub_request(:get, "#{base_url}/anime/1/recommendations")
          .to_return(status: 200, body: { data: [{ entry: { mal_id: 5 }, votes: 10 }] }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.anime(1).recommendations[:data]).to be_a(Array)
      end

      it 'allows chaining .anime(id).relations' do
        stub_request(:get, "#{base_url}/anime/1/relations")
          .to_return(status: 200, body: { data: [{ relation: 'Sequel', entry: [] }] }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.anime(1).relations[:data]).to be_a(Array)
      end

      it 'allows chaining .anime(id).themes' do
        stub_request(:get, "#{base_url}/anime/1/themes")
          .to_return(status: 200, body: { data: { openings: ['OP1'], endings: ['ED1'] } }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.anime(1).themes[:data][:openings]).to be_a(Array)
      end

      it 'allows chaining .anime(id).external' do
        stub_request(:get, "#{base_url}/anime/1/external")
          .to_return(status: 200, body: { data: [{ name: 'Site', url: 'https://example.com' }] }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.anime(1).external[:data]).to be_a(Array)
      end

      it 'allows chaining .anime(id).streaming' do
        stub_request(:get, "#{base_url}/anime/1/streaming")
          .to_return(status: 200, body: { data: [{ name: 'Crunchyroll', url: 'https://crunchyroll.com' }] }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.anime(1).streaming[:data]).to be_a(Array)
      end
    end
  end
end
