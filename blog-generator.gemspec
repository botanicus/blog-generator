#!/usr/bin/env gem build

Gem::Specification.new do |s|
  s.name              = 'blog-generator'
  s.version           = '0.0.1'
  s.authors           = ['James C Russell']
  s.summary           = 'Simple generator of blog APIs.'

  s.add_runtime_dependency('nokogiri', ['~> 1.6'])
end
