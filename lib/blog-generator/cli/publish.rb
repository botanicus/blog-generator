require 'ostruct'
require 'digest'
require 'blog-generator/post'

# Variables.
drafts_dir = 'drafts'
posts_dir  = 'posts'

# Main.
unless ARGV.length == 1
  # abort 'ERROR: The draft command needs only slug as an argument.'
  abort "ERROR: The draft command needs the draft path such as: drafts/hello-world.md"
end

# slug = ARGV.shift
# draft_path = Dir.glob("#{drafts_dir}/#{slug}.{html,md}").first
draft_path = ARGV.shift

slug = draft_path.split('/').last.sub(/\.(html|md)$/, '')

if draft_path.match(/\/\d{4}-\d{2}-\d{2}-/)
  abort "The date will be set when you publish. Just stick to the base slug."
end
# TODO: if there is draft: true metadata, remove.

if post = Dir.glob("#{posts_dir}/*-#{slug}.{html,md}").first
  abort "ERROR: Post #{post} has already been published."
end

unless draft_path
  abort "ERROR: There is no #{slug} with extension html or md in #{drafts_dir}."
end

Dir.mkdir(posts_dir) unless Dir.exists?(posts_dir)

date_slug = Time.now.strftime('%Y-%m-%d')
format    = File.extname(draft_path)[1..-1]
post_path = File.join(posts_dir, "#{date_slug}-#{slug}.#{format}")

site = OpenStruct.new # mock
post = BlogGenerator::Post.new(site, draft_path)

published_at = Time.now.utc.strftime('%d/%m/%Y %H:%M')
body_digest  = Digest::MD5.hexdigest(post.raw_body) # Raw body, so it's with the excerpt as well.

File.open(post_path, 'w') do |file|
  file.puts(post.save(digest: body_digest, published_at: published_at))
end

File.unlink(draft_path)
