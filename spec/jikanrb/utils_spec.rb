# frozen_string_literal: true

require 'spec_helper'
require 'jikanrb/utils'

RSpec.describe Jikanrb::IndifferentHash do
  describe '#initialize' do
    it 'creates an empty hash by default' do
      expect(described_class.new).to be_empty
    end

    it 'initializes with a provided hash' do
      hash = described_class.new(a: 1)
      expect(hash['a']).to eq(1)
    end
  end

  describe 'access' do
    let(:hash) { described_class.new(foo: 'bar', 'baz' => 'qux') }

    it 'allows access by symbol' do
      expect(hash[:foo]).to eq('bar')
      expect(hash[:baz]).to eq('qux')
    end

    it 'allows access by string' do
      expect(hash['foo']).to eq('bar')
      expect(hash['baz']).to eq('qux')
    end

    it 'handles setting values with symbols' do
      hash[:new_key] = 'value'
      expect(hash['new_key']).to eq('value')
    end

    it 'handles setting values with strings' do
      hash['another_key'] = 'value'
      expect(hash[:another_key]).to eq('value')
    end
  end

  describe 'nested access' do
    let(:nested_hash) do
      described_class.new(
        user: {
          name: 'John',
          address: {
            city: 'Tokyo'
          }
        }
      )
    end

    it 'converts nested hashes to IndifferentHash recursively' do
      expect(nested_hash[:user]).to be_a(described_class)
      expect(nested_hash[:user][:address]).to be_a(described_class)
    end

    it 'allows indifferent access on nested hashes' do
      expect(nested_hash['user']['name']).to eq('John')
      expect(nested_hash[:user][:name]).to eq('John')
      expect(nested_hash[:user]['name']).to eq('John')
    end

    it 'allows indifferent access on deeply nested hashes' do
      expect(nested_hash[:user][:address][:city]).to eq('Tokyo')
      expect(nested_hash['user']['address']['city']).to eq('Tokyo')
    end
  end

  describe 'array support' do
    let(:array_hash) do
      described_class.new(
        list: [
          { id: 1, name: 'Item 1' },
          { id: 2, name: 'Item 2' }
        ]
      )
    end

    it 'converts hashes inside arrays to IndifferentHash' do
      expect(array_hash[:list].first).to be_a(described_class)
    end

    it 'allows indifferent access on hashes inside arrays' do
      expect(array_hash[:list][0][:name]).to eq('Item 1')
      expect(array_hash[:list][0]['name']).to eq('Item 1')
    end
  end

  describe '#fetch' do
    let(:hash) { described_class.new(a: 1) }

    it 'fetches values by symbol' do
      expect(hash.fetch(:a)).to eq(1)
    end

    it 'fetches values by string' do
      expect(hash.fetch('a')).to eq(1)
    end

    it 'raises KeyError when key is missing' do
      expect { hash.fetch(:b) }.to raise_error(KeyError)
    end

    it 'returns default value if provided' do
      expect(hash.fetch(:b, 2)).to eq(2)
    end

    it 'executes block if provided' do
      expect(hash.fetch(:b) { 3 }).to eq(3)
    end
  end

  describe '#key?' do
    let(:hash) { described_class.new(a: 1) }

    it 'returns true for existing symbol key accessed by symbol' do
      expect(hash.key?(:a)).to be true
    end

    it 'returns true for existing symbol key accessed by string' do
      expect(hash.key?('a')).to be true
    end

    it 'returns false for non-existent key' do
      expect(hash.key?(:b)).to be false
    end
  end
end
