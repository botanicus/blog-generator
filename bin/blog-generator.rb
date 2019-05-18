#!/usr/bin/env ruby

unless ARGV.length == 1 && Dir.exist?(ARGV.first)
  abort("Usage:  #{$0} [content_directory]")
end

content_directory = ARGV.first
validator = BlogGenerator::ContentDirectoryValidator.new(content_directory)
begin
  validator.validate
rescue => error
  abort("#{error.class}: #{error.message}")
end

puts "~ Validation successful."

generator = BlogGenerator::Generator.new(content_directory)
begin
  generator.generate
rescue => error
  abort("#{error.class}: #{error.message}")
end

puts "~ Post generation successful."
