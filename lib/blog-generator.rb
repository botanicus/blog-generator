# The 'drop-area style' is good, but how do you update posts?
# What if there's never any HTML, rather it's all done on the frontend?
# So we generate indices and what not, but the format stays markdown?
#
# require 'digest'
require 'blog-generator/post'

module BlogGenerator
  class ValidationError < StandardError; end

  class ContentDirectoryValidator
    def initialize(content_directory)
      @content_directory = content_directory
    end

    def validate
      self.validate_one_post_file
      self.validate_is_valid_markdown
      self.validate_image_paths
      true
    end

    def main_file
      Dir.glob("#{@content_directory}/*.md").first
    end

    def post
      @post ||= Post.new(File.read(self.main_file))
    end

    protected
    # There must be exactly 1 file with .md extension in the content directory.
    def validate_one_post_file
      unless Dir.glob("#{@content_directory}/*.md").length == 1
        raise ValidationError, "There must be exactly 1 .md file in #{@content_directory}"
      end
    end

    def validate_is_valid_markdown
      self.document
    rescue => error
      raise ValidationError, "Cannot parse #{self.main_file}: #{error.class}: #{error.message}"
    end

    def validate_image_paths
      self.image_paths.each do |src|
        unless File.exist?(File.join(@content_directory, src))
          raise ValidationError, "Image #{src} doesn't exist in #{@content_directory}"
        end
      end
    end
  end

  class Generator
    def initialize(content_directory)
      @content_directory = content_directory
    end

    def generate
      raise NotImplementedError
    end
  end
end
