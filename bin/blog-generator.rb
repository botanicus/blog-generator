#!/usr/bin/env ruby

# [Usage]
#
# blog-generator.rb [posts dir] [output base path]

require 'blog-generator'

POSTS_DIR, OUTPUT_BASE_PATH = ARGV

unless ARGV.length == 2
  abort "Usage: #{$0} [posts dir] [output base path]"
end

unless File.directory?(POSTS_DIR)
  abort "Posts directory #{POSTS_DIR} doesn't exist."
end

# Parse the posts.
generator = BlogGenerator::Generator.parse(POSTS_DIR)

unless File.directory?(OUTPUT_BASE_PATH)
  puts "~ #{OUTPUT_BASE_PATH} doesn't exist, creating."
  Dir.mkdir(OUTPUT_BASE_PATH)
end

path = File.expand_path(File.join(POSTS_DIR, '..', 'defaults.yml'))
unless File.exist?(path)
  puts "~ Feed configuration file #{path} not found."
end

FEED_DATA = File.exist?(path) ? YAML.load_file(path) : Hash.new

# Generate.

Dir.chdir(OUTPUT_BASE_PATH) do
  # GET /metadata.json
  File.open('metadata.json', 'w') do |file|
    file.puts(FEED_DATA.to_json)
  end

  # GET /api/posts.json
  File.open('posts.json', 'w') do |file|
    # This calls PostList#to_json
    file.puts(JSON.pretty_generate(generator.posts))
  end

  # GET /posts.atom
  File.open('posts.atom', 'w') do |file|
    feed = BlogGenerator::Feed.new(FEED_DATA, generator.posts, 'posts.atom')
    file.puts(feed.render)
  end

  # GET /api/posts/hello-world.json
  Dir.mkdir('posts') unless Dir.exist?('posts')
  generator.posts.each do |post|
    File.open("posts/#{post.slug}.json", 'w') do |file|
      file.puts(JSON.pretty_generate(post))
    end
  end

  # GET /api/tags.json
  File.open('tags.json', 'w') do |file|
    # [{title: x, slug: y}]
    tags = generator.tags.map do |tag, _|
      tag
    end
    file.puts(JSON.pretty_generate(tags))
  end

  Dir.mkdir('tags') unless Dir.exist?('tags')
  generator.tags.each do |tag, posts|
    # GET /api/tags/doxxu.json
    File.open("tags/#{tag[:slug]}.json", 'w') do |file|
      file.puts(JSON.pretty_generate(posts))
    end

    # GET /api/tags/doxxu.atom
    File.open("tags/#{tag[:slug]}.atom", 'w') do |file|
      feed = BlogGenerator::Feed.new(FEED_DATA, posts, "#{tag[:slug]}.atom")
      file.puts(feed.render)
    end
  end
end
