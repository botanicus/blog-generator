module BlogGenerator
  class FileSystemActions
    def initialize(*actions)
      @actions = actions
    end

    def <<(*actions)
      actions.each do |action|
        unless action.respond_to?(:validate) && action.respond_to?(:commit)
          raise TypeError, "Expected object with #validate and #commit methods, got #{action}"
        end

        @actions << action
      end
    end

    # Ruby doesn't allow using #<< with splat, that's why we need a "normal" method.
    alias_method :push, :<<

    def to_a
      @actions
    end

    def validate
      @actions.each do |action|
        action.validate
      rescue => error
        warn "! Error during validating action #{action}" # !!!
        raise error
      end
    end

    def commit
      @actions.each do |action|
        action.commit
      rescue => error
        warn "! Error during commiting action #{action}" # !!!
        raise error
      end
    end
  end

  class FileSystemAction
    def validate
      raise NotImplementedError
    end

    def commit
      raise NotImplementedError
    end

    private
    def run(command)
      puts "$ #{command}"
      system(command)
    end
  end

  class MoveFileAction < FileSystemAction
    attr_reader :source_file, :target_directory
    def initialize(source_file, target_directory)
      @source_file, @target_directory = source_file, "#{target_directory}/"
    end

    def validate
      unless File.file?(@source_file)
        raise ArgumentError, "Source file #{@source_file} doesn't exist"
      end

      unless Dir.exist?(@target_directory)
        raise ArgumentError, "Target directory #{@target_directory} doesn't exist"
      end
    end

    def commit
      run "mv #{@source_file} #{@target_directory}"
    end
  end

  class FileWriteAction < FileSystemAction
    attr_reader :target_file_path, :content
    def initialize(target_file_path, content)
      @target_file_path, @content = target_file_path, content
    end

    def validate
      dirname, basename = File.split(@target_file_path)
      unless Dir.exist?(dirname)
        raise ArgumentError, "Parent directory #{dirname} of #{basename} doesn't exist"
      end
    end

    def commit
      puts "~ Writing #{@target_file_path}"
      File.open(@target_file_path, 'w') do |file|
        file.puts(@content)
      end
    end
  end

  class CreateDirectoryAction < FileSystemAction
    attr_reader :target_directory_path
    def initialize(target_directory_path)
      @target_directory_path = "#{target_directory_path}/"
    end

    def validate
      dirname, basename = File.split(@target_directory_path)
      unless Dir.exist?(dirname)
        raise ArgumentError, "Parent directory #{dirname} of #{basename} doesn't exist"
      end
    end

    def commit
      run "mkdir #{@target_directory_path}"
    end
  end
end
