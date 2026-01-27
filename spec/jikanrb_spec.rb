# frozen_string_literal: true

RSpec.describe Jikanrb do
  it 'has a version number' do
    expect(Jikanrb::VERSION).not_to be_nil
  end

  describe '.configuration' do
    it 'returns a Configuration instance' do
      expect(described_class.configuration).to be_a(Jikanrb::Configuration)
    end

    it 'returns the same instance on multiple calls' do
      config1 = described_class.configuration
      config2 = described_class.configuration
      expect(config1).to be(config2)
    end
  end

  describe '.configure' do
    it 'yields the configuration' do
      expect { |b| described_class.configure(&b) }.to yield_with_args(Jikanrb::Configuration)
    end

    it 'allows setting configuration options' do
      described_class.configure do |config|
        config.read_timeout = 25
        config.max_retries = 7
      end

      expect(described_class.configuration.read_timeout).to eq(25)
      expect(described_class.configuration.max_retries).to eq(7)
    end
  end

  describe '.reset_configuration!' do
    it 'creates a new configuration' do
      old_config = described_class.configuration
      described_class.reset_configuration!
      new_config = described_class.configuration

      expect(new_config).not_to be(old_config)
    end

    it 'resets configuration to defaults' do
      described_class.configure { |c| c.read_timeout = 99 }
      described_class.reset_configuration!

      expect(described_class.configuration.read_timeout).to eq(10)
    end
  end

  describe '.client' do
    it 'returns a Client instance' do
      expect(described_class.client).to be_a(Jikanrb::Client)
    end

    it 'returns the same instance on multiple calls' do
      client1 = described_class.client
      client2 = described_class.client
      expect(client1).to be(client2)
    end

    it 'uses global configuration' do
      described_class.configure { |c| c.read_timeout = 33 }
      client = described_class.client

      expect(client.config.read_timeout).to eq(33)
    end
  end

  describe '.reset_client!' do
    it 'resets the client' do
      old_client = described_class.client
      described_class.reset_client!
      new_client = described_class.client

      expect(new_client).not_to be(old_client)
    end
  end

  describe 'convenience methods' do
    let(:mock_client) { instance_double(Jikanrb::Client) }

    before do
      allow(described_class).to receive(:client).and_return(mock_client)
    end

    describe '.anime' do
      it 'delegates to client.anime' do
        expect(mock_client).to receive(:anime).with(1, full: false)
        described_class.anime(1)
      end

      it 'passes full parameter' do
        expect(mock_client).to receive(:anime).with(1, full: true)
        described_class.anime(1, full: true)
      end
    end

    describe '.manga' do
      it 'delegates to client.manga' do
        expect(mock_client).to receive(:manga).with(1, full: false)
        described_class.manga(1)
      end
    end

    describe '.character' do
      it 'delegates to client.character' do
        expect(mock_client).to receive(:character).with(1)
        described_class.character(1)
      end
    end

    describe '.person' do
      it 'delegates to client.person' do
        expect(mock_client).to receive(:person).with(1)
        described_class.person(1)
      end
    end

    describe '.search_anime' do
      it 'delegates to client.search_anime' do
        expect(mock_client).to receive(:search_anime).with('Naruto', type: 'tv')
        described_class.search_anime('Naruto', type: 'tv')
      end
    end

    describe '.search_manga' do
      it 'delegates to client.search_manga' do
        expect(mock_client).to receive(:search_manga).with('One Piece')
        described_class.search_manga('One Piece')
      end
    end

    describe '.top_anime' do
      it 'delegates to client.top_anime' do
        expect(mock_client).to receive(:top_anime).with(type: 'tv', filter: 'airing', page: 1)
        described_class.top_anime(type: 'tv', filter: 'airing')
      end
    end

    describe '.top_manga' do
      it 'delegates to client.top_manga' do
        expect(mock_client).to receive(:top_manga).with(type: nil, filter: nil, page: 1)
        described_class.top_manga
      end
    end

    describe '.season' do
      it 'delegates to client.season' do
        expect(mock_client).to receive(:season).with(2024, 'winter', page: 1)
        described_class.season(2024, 'winter')
      end
    end

    describe '.season_now' do
      it 'delegates to client.season_now' do
        expect(mock_client).to receive(:season_now).with(page: 1)
        described_class.season_now
      end
    end

    describe '.schedules' do
      it 'delegates to client.schedules' do
        expect(mock_client).to receive(:schedules).with(day: 'monday')
        described_class.schedules(day: 'monday')
      end
    end
  end
end
