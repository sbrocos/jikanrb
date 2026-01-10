# frozen_string_literal: true

require_relative 'lib/jikanrb/version'

Gem::Specification.new do |spec|
  spec.name = 'jikanrb'
  spec.version = Jikanrb::VERSION
  spec.authors = ['Sergio Brocos']
  spec.email = ['sergiobrocos@gmail.com']

  spec.summary = 'Ruby client for Jikan API v4 (Unofficial MyAnimeList API)'
  spec.description = 'A modern, well-documented Ruby wrapper for the Jikan REST API v4. ' \
                     'Provides easy access to anime, manga, characters, and more from MyAnimeList.'
  spec.homepage = 'https://github.com/sbrocos/jikanrb'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['documentation_uri'] = 'https://rubydoc.info/gems/jikanrb'
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/ .rubocop.yml CLAUDE.md AGENTS.md])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Runtime dependecies
  spec.add_dependency 'faraday', '>= 2.0', '< 3.0'
  spec.add_dependency 'faraday-retry', '>= 2.0', '< 3.0'
end
