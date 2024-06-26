# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'rubocop-next'
  spec.version = '1.0.7'

  spec.authors = ['Third Party Transportation Systems LLC']
  spec.email = 'hello@next-tms.com'

  spec.description = 'Rubocop configuration'
  spec.summary = spec.description
  spec.homepage = 'https://github.com/next-tms/rubocop-next'

  spec.metadata = {
    'allowed_push_host' => 'https://rubygems.org',
    'source_code_uri' => "https://github.com/next-tms/rubocop-next/tree/v#{spec.version}"
  }

  spec.files = ['Gemfile', 'rubocop-next.gemspec', 'rubocop.yml', 'LICENSE']

  spec.add_dependency('rubocop', '>= 1.56', '< 1.65')
  spec.add_dependency('rubocop-graphql', '>= 1.4', '< 1.6')
  spec.add_dependency('rubocop-rails', '>= 2.20.2', '< 2.26.0')
  spec.add_dependency('rubocop-rake', '~> 0.6.0')
  spec.add_dependency('rubocop-rspec', '>= 2.23.2', '< 3.1.0')
  spec.add_dependency('rubocop-shopify', '>= 2.14', '< 2.16')

  spec.required_ruby_version = '>= 3.2.0'
end
