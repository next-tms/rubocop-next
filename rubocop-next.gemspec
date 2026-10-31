Gem::Specification.new do |spec|
  spec.name = 'rubocop-next'
  spec.version = '1.0.9'

  spec.authors = ['Third Party Transportation Management Systems LLC']
  spec.email = 'hello@next-tms.com'

  spec.description = 'Rubocop configuration'
  spec.summary = spec.description
  spec.homepage = 'https://github.com/next-tms/rubocop-next'

  spec.metadata = {
    'allowed_push_host' => 'https://rubygems.org',
    'source_code_uri' => "https://github.com/next-tms/rubocop-next/tree/v#{spec.version}"
  }

  spec.files = ['Gemfile', 'rubocop-next.gemspec', 'rubocop.yml', 'LICENSE']

  spec.add_dependency('benchmark')
  spec.add_dependency('rubocop', '>= 1.91', '< 1.93')
  spec.add_dependency('rubocop-graphql', '>= 1.6', '< 1.9')
  spec.add_dependency('rubocop-rails', '>= 2.29', '< 2.39')
  spec.add_dependency('rubocop-rake', '~> 0.7.0')
  spec.add_dependency('rubocop-rspec', '>= 3.5', '< 3.11')
  spec.add_dependency('rubocop-rspec_rails', '>= 2.31', '< 2.33')
  spec.add_dependency('tsort')

  spec.required_ruby_version = '>= 3.3.0'
end
