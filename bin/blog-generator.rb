#!/usr/bin/env ruby

require 'blog-generator'

unless ARGV.length == 2 && Dir.exist?(ARGV.first)
  abort("Usage:  #{$0} [content_directory] [output_directory]")
end

content_directory, output_directory = ARGV
validator = BlogGenerator::ContentDirectoryValidator.new(content_directory)
begin
  validator.validate
rescue => error
  abort("#{error.class}: #{error.message}")
end

puts "~ Validation successful."

generator = BlogGenerator::Generator.new(content_directory, output_directory)
begin
  actions = generator.generate
  actions.validate
  actions.commit
rescue => error
  abort("#{error.class}: #{error.message}")
end

puts "~ Post generation successful."
