# frozen_string_literal: true

RSpec.describe Jikanrb::Resources::BaseResource do
  subject(:resource) { described_class.new(client, resource_id) }

  let(:client) { Jikanrb::Client.new }
  let(:resource_id) { 1 }
  let(:base_url) { 'https://api.jikan.moe/v4' }

  describe '#initialize' do
    it 'stores the client reference' do
      expect(resource.instance_variable_get(:@client)).to eq(client)
    end

    it 'stores the resource id' do
      expect(resource.id).to eq(resource_id)
    end
  end

  describe '#id' do
    it 'returns the resource ID' do
      expect(resource.id).to eq(1)
    end

    it 'is read-only' do
      expect(resource).not_to respond_to(:id=)
    end
  end

  describe '#get (private)' do
    it 'delegates GET requests to the client' do
      response_body = { data: { mal_id: 1, name: 'Test' } }.to_json

      stub_request(:get, "#{base_url}/test/1")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })

      result = resource.send(:get, 'test/1')

      expect(result).to be_a(Hash)
      expect(result[:data][:mal_id]).to eq(1)
    end

    it 'passes query parameters to the client' do
      response_body = { data: [], pagination: { current_page: 2 } }.to_json

      stub_request(:get, "#{base_url}/test/1/items")
        .with(query: { page: 2 })
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })

      result = resource.send(:get, 'test/1/items', page: 2)

      expect(result[:pagination][:current_page]).to eq(2)
    end

    it 'returns IndifferentHash for flexible key access' do
      response_body = { data: { mal_id: 1, title: 'Test' } }.to_json

      stub_request(:get, "#{base_url}/test/1")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })

      result = resource.send(:get, 'test/1')

      expect(result[:data][:title]).to eq('Test')
      expect(result['data']['title']).to eq('Test')
    end

    it 'propagates client errors' do
      stub_request(:get, "#{base_url}/test/999")
        .to_return(status: 404, body: { error: 'Not found' }.to_json)

      expect { resource.send(:get, 'test/999') }.to raise_error(Jikanrb::NotFoundError)
    end
  end

  describe 'subclass usage' do
    let(:test_resource_class) do
      Class.new(described_class) do
        def info
          get("people/#{@id}")
        end

        def anime
          get("people/#{@id}/anime")
        end
      end
    end

    let(:test_resource) { test_resource_class.new(client, 1) }

    it 'allows subclasses to define resource methods' do
      response_body = { data: { mal_id: 1, name: 'Test Person' } }.to_json

      stub_request(:get, "#{base_url}/people/1")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })

      result = test_resource.info

      expect(result[:data][:name]).to eq('Test Person')
    end

    it 'allows subclasses to access sub-resources' do
      response_body = { data: [{ position: 'Director', anime: { title: 'Test Anime' } }] }.to_json

      stub_request(:get, "#{base_url}/people/1/anime")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })

      result = test_resource.anime

      expect(result[:data]).to be_an(Array)
      expect(result[:data].first[:position]).to eq('Director')
    end
  end
end
