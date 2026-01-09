# frozen_string_literal: true

RSpec.describe Jikanrb::Configuration do
  subject(:config) { described_class.new }

  describe '#initialize' do
    it 'sets default base_url' do
      expect(config.base_url).to eq('https://api.jikan.moe/v4')
    end

    it 'sets default open_timeout' do
      expect(config.open_timeout).to eq(5)
    end

    it 'sets default read_timeout' do
      expect(config.read_timeout).to eq(10)
    end

    it 'sets default max_retries' do
      expect(config.max_retries).to eq(3)
    end

    it 'sets default retry_interval' do
      expect(config.retry_interval).to eq(1)
    end

    it 'sets default user_agent with version' do
      expect(config.user_agent).to eq("Jikanrb Ruby Gem/#{Jikanrb::VERSION}")
    end

    it 'sets default logger to nil' do
      expect(config.logger).to be_nil
    end
  end

  describe 'attribute accessors' do
    it 'allows setting base_url' do
      config.base_url = 'https://custom.api.com'
      expect(config.base_url).to eq('https://custom.api.com')
    end

    it 'allows setting open_timeout' do
      config.open_timeout = 15
      expect(config.open_timeout).to eq(15)
    end

    it 'allows setting read_timeout' do
      config.read_timeout = 30
      expect(config.read_timeout).to eq(30)
    end

    it 'allows setting max_retries' do
      config.max_retries = 5
      expect(config.max_retries).to eq(5)
    end

    it 'allows setting retry_interval' do
      config.retry_interval = 2
      expect(config.retry_interval).to eq(2)
    end

    it 'allows setting user_agent' do
      config.user_agent = 'CustomAgent/1.0'
      expect(config.user_agent).to eq('CustomAgent/1.0')
    end

    it 'allows setting logger' do
      logger = Logger.new($stdout)
      config.logger = logger
      expect(config.logger).to eq(logger)
    end
  end
end
