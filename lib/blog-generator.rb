require 'json'
require 'time' # #iso8601
require 'blog-generator/post'
require 'blog-generator/file-system-actions'

module BlogGenerator
  class ValidationError < StandardError; end

  class ContentDirectoryHandler
    # content_directory: i. e. drop-area/, it doesn't have any name specific to the post.
    def initialize(content_directory)
      @content_directory = content_directory
    end

    def main_file
      Dir.glob("#{@content_directory}/*.md").first
    end

    def post
      slug = File.basename(self.main_file).split('.').first
      @post ||= Post.new(slug, File.read(self.main_file))
    end
  end

  class ContentDirectoryValidator < ContentDirectoryHandler
    def validate
      self.validate_one_post_file
      self.validate_is_valid_markdown
      self.validate_image_paths
      true
    end

    protected
    # There must be exactly 1 file with .md extension in the content directory.
    def validate_one_post_file
      unless Dir.glob("#{@content_directory}/*.md").length == 1
        raise ValidationError, "There must be exactly 1 .md file in #{@content_directory}"
      end
    end

    def validate_is_valid_markdown
      self.post.validate
    end

    def validate_image_paths
      self.post.image_paths.each do |src|
        unless File.exist?(File.join(@content_directory, src))
          raise ValidationError, "Image #{src} doesn't exist in #{@content_directory}"
        end
      end
    end
  end

  class Generator < ContentDirectoryHandler
    def initialize(content_directory, output_directory)
      @content_directory = content_directory
      @output_directory = output_directory
    end

    def output_post_directory
      File.join(@output_directory, self.output_post_basename)
    end

    def output_post_basename
      "#{Time.now.strftime('%Y-%m-%d')}-#{self.post.slug}"
    end

    def generate
      actions = FileSystemActions.new
      actions << CreateDirectoryAction.new(self.output_post_directory)

      Dir.glob("#{@content_directory}/*").each do |file|
        if File.file?(file) && File.basename(file) != File.basename(self.main_file)
          actions << MoveFileAction.new(file, self.output_post_directory)
        end
      end

      json = self.post.as_json.merge(publishedAt: Time.now.iso8601).to_json
      actions << FileWriteAction.new(File.join(self.output_post_directory, "#{self.post.slug}.json"), json)

      actions
    end
  end
end
