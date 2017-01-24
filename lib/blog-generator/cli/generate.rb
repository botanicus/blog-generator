require 'ostruct'
require 'fileutils'
require 'blog-generator'

POSTS_DIR, OUTPUT_BASE_PATH = ARGV.map { |i| i.chomp('/') }


unless ARGV.length == 2
  abort "Usage: #{$0} [posts dir] [output base path]"
end

unless File.directory?(POSTS_DIR)
  abort "Posts directory #{POSTS_DIR} doesn't exist."
end

if Dir.exists?("#{OUTPUT_BASE_PATH}_prev") # If it does, the last build crashed.
  puts "~ Last build crashed. Reusing #{OUTPUT_BASE_PATH}_prev."
elsif (! Dir.exists?("#{OUTPUT_BASE_PATH}_prev")) && Dir.exists?(OUTPUT_BASE_PATH) # otherwise it's first run.
  FileUtils.mv(OUTPUT_BASE_PATH, "#{OUTPUT_BASE_PATH}_prev") # So we don't get any artifacts.
end

unless Dir.exists?(OUTPUT_BASE_PATH)
  puts "~ #{OUTPUT_BASE_PATH} doesn't exist, creating."
  Dir.mkdir(OUTPUT_BASE_PATH)
end

OLD_POSTS = Dir.glob("#{OUTPUT_BASE_PATH}_prev/posts/*.json").reduce(Hash.new) do |posts, path|
  post = JSON.parse(File.read(path))
  posts.merge(post['slug'] => post)
end

path = File.expand_path(File.join(POSTS_DIR, '..', 'defaults.yml'))
unless File.exist?(path)
  puts "~ Feed configuration file #{path} not found."
end

# Parse the posts.
site = OpenStruct.new(File.exist?(path) ? YAML.load_file(path) : Hash.new)
generator = BlogGenerator::Generator.parse(site, POSTS_DIR, OLD_POSTS)

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
  file 'metadata.json', JSON.pretty_generate(site.instance_variable_get(:@table))

  # GET /api/posts.json
  # This calls PostList#to_json
  file 'posts.json', JSON.pretty_generate(generator.posts)

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
    body = {tag: tag, posts: posts}
    file "tags/#{tag[:slug]}.json", JSON.pretty_generate(body)
  end
end

FileUtils.rm_rf("#{OUTPUT_BASE_PATH}_prev") # Has to be forced, otherwise fails on the first run.
