# frozen_string_literal: true

RSpec.describe Jikanrb::Resources::CharacterResource do
  subject(:resource) { described_class.new(client, character_id) }

  let(:client) { Jikanrb::Client.new }
  let(:character_id) { 1 }
  let(:base_url) { 'https://api.jikan.moe/v4' }

  describe '#initialize' do
    it 'stores the client reference' do
      expect(resource.instance_variable_get(:@client)).to eq(client)
    end

    it 'stores the character ID' do
      expect(resource.instance_variable_get(:@id)).to eq(character_id)
    end
  end

  describe '#info' do
    context 'when fetching basic info' do
      let(:response_body) do
        {
          data: {
            mal_id: 1,
            name: 'Spike Spiegel',
            name_kanji: 'スパイク・スピーゲル',
            nicknames: ['Spike']
          }
        }.to_json
      end

      before do
        stub_request(:get, "#{base_url}/characters/#{character_id}")
          .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns character details as hash' do
        expect(resource.info).to be_a(Hash)
      end

      it 'returns correct mal_id with symbol access' do
        expect(resource.info[:data][:mal_id]).to eq(1)
      end

      it 'returns correct name_kanji with string access' do
        expect(resource.info['data']['name_kanji']).to eq('スパイク・スピーゲル')
      end
    end

    context 'when fetching full info' do
      let(:response_body) do
        {
          data: {
            mal_id: 1,
            name: 'Spike Spiegel',
            anime: [],
            manga: [],
            voices: []
          }
        }.to_json
      end

      before do
        stub_request(:get, "#{base_url}/characters/#{character_id}/full")
          .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns extended character details' do
        result = resource.info(full: true)

        expect(result[:data][:mal_id]).to eq(1)
        expect(result[:data][:anime]).to be_a(Array)
        expect(result[:data][:manga]).to be_a(Array)
        expect(result[:data][:voices]).to be_a(Array)
      end
    end
  end

  describe '#animes' do
    let(:response_body) do
      {
        data: [
          { role: 'Main', anime: { mal_id: 1, title: 'Cowboy Bebop' } },
          { role: 'Main', anime: { mal_id: 5, title: 'Cowboy Bebop: Tengoku no Tobira' } }
        ]
      }.to_json
    end

    before do
      stub_request(:get, "#{base_url}/characters/#{character_id}/anime")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it "returns character's anime appearances as array" do
      result = resource.animes

      expect(result[:data]).to be_a(Array)
      expect(result[:data].length).to eq(2)
      expect(result[:data].first[:role]).to eq('Main')
    end

    it 'supports string access for anime data' do
      expect(resource.animes['data'].first['anime']['title']).to eq('Cowboy Bebop')
    end
  end

  describe '#mangas' do
    let(:response_body) do
      {
        data: [
          { role: 'Main', manga: { mal_id: 173, title: 'Cowboy Bebop' } }
        ]
      }.to_json
    end

    before do
      stub_request(:get, "#{base_url}/characters/#{character_id}/manga")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it "returns character's manga appearances" do
      result = resource.mangas

      expect(result[:data]).to be_a(Array)
      expect(result[:data].first[:role]).to eq('Main')
    end

    it 'supports string access for manga data' do
      expect(resource.mangas['data'].first['manga']['title']).to eq('Cowboy Bebop')
    end
  end

  describe '#voices' do
    let(:response_body) do
      {
        data: [
          { language: 'Japanese', person: { mal_id: 11, name: 'Koichi Yamadera' } },
          { language: 'English', person: { mal_id: 468, name: 'Steve Blum' } }
        ]
      }.to_json
    end

    before do
      stub_request(:get, "#{base_url}/characters/#{character_id}/voices")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it "returns character's voice actors" do
      result = resource.voices

      expect(result[:data]).to be_a(Array)
      expect(result[:data].length).to eq(2)
      expect(result[:data].first[:language]).to eq('Japanese')
    end

    it 'includes voice actor person information' do
      result = resource.voices

      expect(result[:data].first[:person][:name]).to eq('Koichi Yamadera')
      expect(result['data'].last['person']['name']).to eq('Steve Blum')
    end
  end

  describe '#pictures' do
    let(:response_body) do
      {
        data: [
          { jpg: { image_url: 'https://cdn.myanimelist.net/images/characters/4/50197.jpg' } },
          { jpg: { image_url: 'https://cdn.myanimelist.net/images/characters/4/50198.jpg' } }
        ]
      }.to_json
    end

    before do
      stub_request(:get, "#{base_url}/characters/#{character_id}/pictures")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it "returns character's pictures" do
      result = resource.pictures

      expect(result[:data]).to be_a(Array)
      expect(result[:data].length).to eq(2)
      expect(result[:data].first[:jpg][:image_url]).to include('myanimelist.net')
    end
  end

  describe 'Client#character fluent API integration' do
    describe '#character' do
      it 'returns a CharacterResource instance' do
        expect(client.character(1)).to be_a(described_class)
      end

      it 'passes the correct ID to the resource' do
        expect(client.character(123).instance_variable_get(:@id)).to eq(123)
      end

      it 'passes the client reference to the resource' do
        expect(client.character(1).instance_variable_get(:@client)).to eq(client)
      end
    end

    describe 'fluent chaining' do
      it 'allows chaining .character(id).info' do
        stub_request(:get, "#{base_url}/characters/1")
          .to_return(status: 200, body: { data: { mal_id: 1, name: 'Spike Spiegel' } }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.character(1).info[:data][:name]).to eq('Spike Spiegel')
      end

      it 'allows chaining .character(id).info(full: true)' do
        stub_request(:get, "#{base_url}/characters/1/full")
          .to_return(status: 200, body: { data: { mal_id: 1, name: 'Spike Spiegel', anime: [] } }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.character(1).info(full: true)[:data][:anime]).to be_a(Array)
      end

      it 'allows chaining .character(id).animes' do
        stub_request(:get, "#{base_url}/characters/1/anime")
          .to_return(status: 200, body: { data: [{ role: 'Main', anime: { mal_id: 1 } }] }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.character(1).animes[:data]).to be_a(Array)
      end

      it 'allows chaining .character(id).mangas' do
        stub_request(:get, "#{base_url}/characters/1/manga")
          .to_return(status: 200, body: { data: [{ role: 'Main', manga: { mal_id: 1 } }] }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.character(1).mangas[:data]).to be_a(Array)
      end

      it 'allows chaining .character(id).voices' do
        stub_request(:get, "#{base_url}/characters/1/voices")
          .to_return(status: 200, body: { data: [{ language: 'Japanese', person: { mal_id: 1 } }] }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.character(1).voices[:data]).to be_a(Array)
      end

      it 'allows chaining .character(id).pictures' do
        stub_request(:get, "#{base_url}/characters/1/pictures")
          .to_return(status: 200, body: { data: [{ jpg: { image_url: 'https://example.com/pic.jpg' } }] }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        expect(client.character(1).pictures[:data]).to be_a(Array)
      end
    end
  end
end
