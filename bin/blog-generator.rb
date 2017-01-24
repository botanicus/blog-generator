#!/usr/bin/env ruby

command  = ARGV.shift
commands = %w{draft generate ignore_update publish update}
if commands.include?(command)
  require "blog-generator/cli/#{command}"
else
  abort <<-EOF
[Usage]

#{$0} generate [output base path]
#{$0} generate [output base path] --include-drafts
#{$0} draft [slug].[extension]
#{$0} publish [slug]
#{$0} update [slug]
#{$0} ignore_update [slug]

[Defaults]

Posts dir is assumed to be posts/ in the same directory as the output base path.
Drafts dir is assumed to be drafts/ in the same directory as the output base path.
  EOF
end
