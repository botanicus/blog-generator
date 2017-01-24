require 'ostruct'
require 'fileutils'
require 'blog-generator'

# Variables.
drafts_dir = 'drafts'
posts_dir  = 'posts'

# Main.
unless (1..2).include?(ARGV.length)
  abort 'The generate command needs only output directory as an argument with --include-drafts being optional.'
end

output_dir = ARGV.shift.chomp('/')
include_drafts = true if ARGV.shift == '--include-drafts'

unless File.directory?(posts_dir)
  abort "Posts directory #{posts_dir} doesn't exist."
end

unless Dir.exists?(output_dir)
  puts "~ #{output_dir} doesn't exist, creating."
  Dir.mkdir(output_dir)
else
  FileUtils.rm_rf("#{output_dir}/*")
end

site_defaults_path = File.expand_path(File.join(posts_dir, '..', 'defaults.yml'))
unless File.exist?(site_defaults_path)
  puts "~ Feed configuration file #{site_defaults_path} not found." # Do we still need it?
end

# Parse the posts.
site = OpenStruct.new(File.exist?(site_defaults_path) ? YAML.load_file(site_defaults_path) : Hash.new)
generator = BlogGenerator::Generator.parse(site, posts_dir, include_drafts ? drafts_dir : false)

# Generate.
generator.validate!

def file(path, content)
  puts "~ #{path}"
  File.open(path, 'w') do |file|
    file.puts(content)
  end
end

Dir.chdir(output_dir) do
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
