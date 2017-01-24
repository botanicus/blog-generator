require 'digest'
require 'blog-generator/post'

# Variables.
posts_dir  = 'posts'

# Main.
unless ARGV.length == 1
  abort 'ERROR: The update command needs only slug as an argument.'
end

slug = ARGV.shift
post_path = Dir.glob("#{posts_dir}/*-#{slug}.{html,md}").first

unless post_path
  abort "ERROR: There is no #{slug} with extension html or md in #{posts_dir}."
end

site = OpenStruct.new # mock
post = BlogGenerator::Post.new(site, post_path)

updated_at  = Time.now.utc.strftime('%d/%m/%Y %H:%M')
body_digest = Digest::MD5.hexdigest(post.raw_body) # Raw body, so it's with the excerpt as well.

if body_digest == post.metadata[:digest]
  abort 'ERROR: The MD5 digest of the body is the same, which means the post has not been updated.'
end

File.open(post_path, 'w') do |file|
  file.puts(post.save(digest: body_digest, updated_at: updated_at))
end
