#!/usr/bin/env gem build

Gem::Specification.new do |s|
  s.name        = 'blog-generator'
  s.version     = '0.0.3'
  s.authors     = ['James C Russell']
  s.email       = 'james@101ideas.cz'
  s.homepage    = 'http://github.com/botanicus/blog-generator'
  s.summary     = 'Simple generator of blog APIs.'
  s.description = '...'
  s.license     = 'MIT'

  s.files       = Dir.glob('{bin,lib}/**/*.rb') + ['README.md']
  s.executables = Dir['bin/*'].map(&File.method(:basename))

  s.add_runtime_dependency('nokogiri', ['~> 1.6'])
end
