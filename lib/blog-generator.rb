require 'json'
require 'time' # #iso8601
require 'blog-generator/post'
require 'blog-generator/models'
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

    def output_posts_directory
      File.join(@output_directory, 'posts')
    end

    def output_post_directory
      File.join(self.output_posts_directory, self.output_post_basename)
    end

    def output_post_basename
      "#{Time.now.strftime('%Y-%m-%d')}-#{self.post.slug}"
    end

    def output_tags_directory
      File.join(@output_directory, 'tags')
    end

    def generate
      actions, published_at = FileSystemActions.new, Time.now

      actions << CreateDirectoryAction.new(self.output_posts_directory)
      actions << CreateDirectoryAction.new(self.output_post_directory)

      Dir.glob("#{@content_directory}/*").each do |file|
        if File.file?(file) && File.basename(file) != File.basename(self.main_file)
          actions << MoveFileAction.new(file, self.output_post_directory)
        end
      end

      json = Models::FullPostFromPost.new(self.post).as_json(published_at).to_json
      actions << FileWriteAction.new(File.join(self.output_post_directory, "#{self.post.slug}.json"), json)

      actions << self.generate_index(published_at)
      actions << CreateDirectoryAction.new(self.output_tags_directory)
      actions.push(*self.generate_tag_files(self.post.header[:tags], published_at))

      actions
    end

    def existing_posts
      posts = Array.new

      if Dir.exist?(self.output_posts_directory) # On the first run, it will not exist until the actions are committed.
        Dir.glob("#{self.output_posts_directory}/*/*.json").each do |file|
          posts << JSON.parse(file)
        rescue => error
          warn "~ Error occurred when parsing #{file}" ###
          raise error
        end
      end

      posts
    end

    # The current post doesn't exist as a JSON file yet.
    def all_posts(published_at)
      self.existing_posts << Models::PostIndexFromPost.new(self.post).as_json(published_at)
    end

    def post_data(post)
      Models::PostFromStoredPost.new(post).as_json
    end

    def generate_index(published_at)
      posts = self.all_posts(published_at).map { |post| self.post_data(post) }
      FileWriteAction.new(File.join(@output_directory, 'posts.json'), posts.to_json)
    end

    def generate_tag_files(tags, published_at)
      tags.map do |tag_name|
        posts = self.all_posts(published_at).
          select { |post| post.fetch(:tags).include?(tag_name) }.
          map { |post| Models::PostFromStoredPost.new(post) }

        tag_data = Models::Tag.new(tag_name, posts).as_json(published_at)

        FileWriteAction.new(File.join(@output_directory, 'tags', "#{tag_name}.json"), tag_data.to_json)
      end
    end
  end
end
