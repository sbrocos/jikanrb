# frozen_string_literal: true

RSpec.describe Jikanrb::Resources::PersonResource do
  subject(:resource) { described_class.new(client, person_id) }

  let(:client) { Jikanrb::Client.new }
  let(:person_id) { 1 }
  let(:base_url) { 'https://api.jikan.moe/v4' }

  describe '#initialize' do
    it 'stores the client reference' do
      expect(resource.instance_variable_get(:@client)).to eq(client)
    end

    it 'stores the person ID' do
      expect(resource.instance_variable_get(:@id)).to eq(person_id)
    end
  end

  describe '#info' do
    context 'when fetching basic info' do
      let(:response_body) do
        {
          data: {
            mal_id: 1,
            name: 'Tomokazu Seki',
            given_name: '智一',
            family_name: '関'
          }
        }.to_json
      end

      before do
        stub_request(:get, "#{base_url}/people/#{person_id}")
          .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns person details as hash' do
        expect(resource.info).to be_a(Hash)
      end

      it 'returns correct mal_id with symbol access' do
        expect(resource.info[:data][:mal_id]).to eq(1)
      end

      it 'returns correct name with string access' do
        expect(resource.info['data']['name']).to eq('Tomokazu Seki')
      end
    end

    context 'when fetching full info' do
      let(:response_body) do
        {
          data: {
            mal_id: 1,
            name: 'Tomokazu Seki',
            voices: [],
            anime: [],
            manga: []
          }
        }.to_json
      end

      before do
        stub_request(:get, "#{base_url}/people/#{person_id}/full")
          .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns extended person details' do
        result = resource.info(full: true)

        expect(result[:data][:mal_id]).to eq(1)
        expect(result[:data][:voices]).to be_a(Array)
        expect(result[:data][:anime]).to be_a(Array)
      end
    end
  end

  describe '#animes' do
    let(:response_body) do
      {
        data: [
          { position: 'Director', anime: { mal_id: 1, title: 'Cowboy Bebop' } },
          { position: 'Producer', anime: { mal_id: 5, title: 'Cowboy Bebop: Tengoku no Tobira' } }
        ]
      }.to_json
    end

    before do
      stub_request(:get, "#{base_url}/people/#{person_id}/anime")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it "returns person's anime staff positions as array" do
      result = resource.animes

      expect(result[:data]).to be_a(Array)
      expect(result[:data].first[:position]).to eq('Director')
    end

    it 'supports both symbol and string access' do
      expect(resource.animes['data'].first['anime']['title']).to eq('Cowboy Bebop')
    end
  end

  describe '#mangas' do
    let(:response_body) do
      {
        data: [
          { position: 'Story & Art', manga: { mal_id: 1, title: 'Monster' } }
        ]
      }.to_json
    end

    before do
      stub_request(:get, "#{base_url}/people/#{person_id}/manga")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it "returns person's manga work positions" do
      result = resource.mangas

      expect(result[:data]).to be_a(Array)
      expect(result[:data].first[:position]).to eq('Story & Art')
    end

    it 'supports string access' do
      expect(resource.mangas['data'].first['manga']['title']).to eq('Monster')
    end
  end

  describe '#voices' do
    let(:response_body) do
      {
        data: [
          { role: 'Main', character: { mal_id: 1, name: 'Spike Spiegel' },
            anime: { mal_id: 1, title: 'Cowboy Bebop' } },
          { role: 'Supporting', character: { mal_id: 100, name: 'Another Character' },
            anime: { mal_id: 20, title: 'Naruto' } }
        ]
      }.to_json
    end

    before do
      stub_request(:get, "#{base_url}/people/#{person_id}/voices")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it "returns person's voice acting roles" do
      result = resource.voices

      expect(result[:data]).to be_a(Array)
      expect(result[:data].length).to eq(2)
      expect(result[:data].first[:role]).to eq('Main')
    end

    it 'includes character and anime information' do
      result = resource.voices

      expect(result[:data].first[:character][:name]).to eq('Spike Spiegel')
      expect(result['data'].first['anime']['title']).to eq('Cowboy Bebop')
    end
  end

  describe '#pictures' do
    let(:response_body) do
      {
        data: [
          { jpg: { image_url: 'https://cdn.myanimelist.net/images/voiceactors/1/123.jpg' } },
          { jpg: { image_url: 'https://cdn.myanimelist.net/images/voiceactors/1/456.jpg' } }
        ]
      }.to_json
    end

    before do
      stub_request(:get, "#{base_url}/people/#{person_id}/pictures")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it "returns person's pictures" do
      result = resource.pictures

      expect(result[:data]).to be_a(Array)
      expect(result[:data].length).to eq(2)
      expect(result[:data].first[:jpg][:image_url]).to include('myanimelist.net')
    end
  end

  describe 'Client#person fluent API integration' do
    describe '#person' do
      it 'returns a PersonResource instance' do
        expect(client.person(1)).to be_a(described_class)
      end

      it 'passes the correct ID to the resource' do
        expect(client.person(123).instance_variable_get(:@id)).to eq(123)
      end

      it 'passes the client reference to the resource' do
        expect(client.person(1).instance_variable_get(:@client)).to eq(client)
      end
    end

    describe 'fluent chaining' do
      it 'allows chaining .person(id).info' do
        stub_request(:get, "#{base_url}/people/1")
          .to_return(status: 200, body: { data: { mal_id: 1, name: 'Tomokazu Seki' } }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.person(1).info[:data][:name]).to eq('Tomokazu Seki')
      end

      it 'allows chaining .person(id).info(full: true)' do
        stub_request(:get, "#{base_url}/people/1/full")
          .to_return(status: 200, body: { data: { mal_id: 1, name: 'Tomokazu Seki', voices: [] } }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.person(1).info(full: true)[:data][:voices]).to be_a(Array)
      end

      it 'allows chaining .person(id).animes' do
        stub_request(:get, "#{base_url}/people/1/anime")
          .to_return(status: 200, body: { data: [{ position: 'Director', anime: { mal_id: 1 } }] }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.person(1).animes[:data]).to be_a(Array)
      end

      it 'allows chaining .person(id).mangas' do
        stub_request(:get, "#{base_url}/people/1/manga")
          .to_return(status: 200, body: { data: [{ position: 'Author', manga: { mal_id: 1 } }] }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.person(1).mangas[:data]).to be_a(Array)
      end

      it 'allows chaining .person(id).voices' do
        stub_request(:get, "#{base_url}/people/1/voices")
          .to_return(status: 200, body: { data: [{ role: 'Main', character: { mal_id: 1 } }] }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.person(1).voices[:data]).to be_a(Array)
      end

      it 'allows chaining .person(id).pictures' do
        stub_request(:get, "#{base_url}/people/1/pictures")
          .to_return(status: 200, body: { data: [{ jpg: { image_url: 'https://example.com/pic.jpg' } }] }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.person(1).pictures[:data]).to be_a(Array)
      end
    end
  end
end
