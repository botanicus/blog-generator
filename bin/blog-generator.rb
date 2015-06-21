#!/usr/bin/env ruby

# [Usage]
#
# blog-generator.rb [posts dir] [output base path]

require 'ostruct'
require 'blog-generator'

POSTS_DIR, OUTPUT_BASE_PATH = ARGV

unless ARGV.length == 2
  abort "Usage: #{$0} [posts dir] [output base path]"
end

unless File.directory?(POSTS_DIR)
  abort "Posts directory #{POSTS_DIR} doesn't exist."
end

unless File.directory?(OUTPUT_BASE_PATH)
  puts "~ #{OUTPUT_BASE_PATH} doesn't exist, creating."
  Dir.mkdir(OUTPUT_BASE_PATH)
end

path = File.expand_path(File.join(POSTS_DIR, '..', 'defaults.yml'))
unless File.exist?(path)
  puts "~ Feed configuration file #{path} not found."
end

# Parse the posts.
site = OpenStruct.new(File.exist?(path) ? YAML.load_file(path) : Hash.new)
generator = BlogGenerator::Generator.parse(site, POSTS_DIR)

# Generate.

def file(path, content)
  puts "~ #{path}"
  File.open(path, 'w') do |file|
    file.puts(content)
  end
end

Dir.chdir(OUTPUT_BASE_PATH) do
  # GET /metadata.json
  # TODO: Refactor this, it's evil.
  file 'metadata.json', site.instance_variable_get(:@table).to_json

  # GET /api/posts.json
  # This calls PostList#to_json
  file 'posts.json', JSON.pretty_generate(generator.posts)

  # GET /posts.atom
  feed = BlogGenerator::Feed.new(site, generator.posts, 'posts.atom')
  file 'posts.atom', feed.render

  # GET /api/posts/hello-world.json
  Dir.mkdir('posts') unless Dir.exist?('posts')
  generator.posts.each do |post|
    file "posts/#{post.slug}.json", JSON.pretty_generate(post)
  end

  # GET /api/tags.json
  file 'tags.json', JSON.pretty_generate(generator.tags.keys)

  Dir.mkdir('tags') unless Dir.exist?('tags')
  generator.tags.each do |tag, posts|
    # GET /api/tags/doxxu.json
    file "tags/#{tag[:slug]}.json", JSON.pretty_generate(posts)

    # GET /api/tags/doxxu.atom
    feed = BlogGenerator::Feed.new(site, posts, "#{tag[:slug]}.atom")
    file "tags/#{tag[:slug]}.atom", feed.render
  end
end
