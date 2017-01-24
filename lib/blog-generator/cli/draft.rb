# Variables.
drafts_dir = 'drafts'
posts_dir  = 'posts'

# Main.
unless ARGV.length == 1
  abort 'The draft command needs only slug or slug.extension as an argument.'
end

if ARGV.first.split('.').length == 2
  slug, format = ARGV.shift.split('.')
else
  slug, format = ARGV.shift, 'html'
end

unless %w{html md}.include?(format)
  abort("BlogGenerator doesn't support #{format}.")
end

draft_path = "#{drafts_dir}/#{slug}.#{format}"

if File.exist?(draft_path)
  abort "ERROR: Draft #{draft_path} already exists."
elsif post = Dir.glob("#{posts_dir}/*-#{slug}.*").first
  abort "ERROR: Slug #{slug} is already being used by #{post}."
end

# The template is actually the same for both HTML and MD.
template = <<-EOF
title: #{slug.tr('-', ' ').capitalize}
tags: []
---

<p id="excerpt">
</p>

<!-- Headings start from h2, since h1 is the title of the article. -->
EOF

Dir.mkdir(drafts_dir) unless Dir.exists?(drafts_dir)

File.open(draft_path, 'w') do |file|
  file.puts(template)
end

puts "~ Draft #{draft_path} has been created."
