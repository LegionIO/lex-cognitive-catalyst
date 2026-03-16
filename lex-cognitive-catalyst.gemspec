# frozen_string_literal: true

require_relative 'lib/legion/extensions/cognitive_catalyst/version'

Gem::Specification.new do |spec|
  spec.name    = 'lex-cognitive-catalyst'
  spec.version = Legion::Extensions::CognitiveCatalyst::VERSION
  spec.authors = ['Esity']
  spec.email   = ['matthewdiverson@gmail.com']

  spec.summary     = 'Cognitive catalysis acceleration for LegionIO agentic architecture'
  spec.description = 'Models how certain thoughts and experiences act as chemical catalysts — ' \
                     'accelerating cognitive reactions without being consumed. Catalysts lower ' \
                     'the activation energy for synthesis, decomposition, exchange, neutralization, ' \
                     'and precipitation reactions between ideas.'
  spec.homepage    = 'https://github.com/LegionIO/lex-cognitive-catalyst'
  spec.license     = 'MIT'

  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']      = spec.homepage
  spec.metadata['source_code_uri']   = 'https://github.com/LegionIO/lex-cognitive-catalyst'
  spec.metadata['documentation_uri'] = 'https://github.com/LegionIO/lex-cognitive-catalyst'
  spec.metadata['changelog_uri']     = 'https://github.com/LegionIO/lex-cognitive-catalyst'
  spec.metadata['bug_tracker_uri']   = 'https://github.com/LegionIO/lex-cognitive-catalyst/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(__dir__) { `git ls-files -z`.split("\x0") }
  spec.require_paths = ['lib']
  spec.add_development_dependency 'legion-gaia'
end
