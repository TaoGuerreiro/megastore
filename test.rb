require 'find'

# Define the path for the output file
output_file_path = 'resume.txt'
# Extensions to ignore
ignored_extensions = ['.jpeg', '.mp4', '.png', '.jpg']
# Directories to include
included_directories = ['components', 'models', 'controllers', 'helpers', 'services', 'views', 'javascript', 'db']

# Open the output file in write mode
File.open(output_file_path, 'w:UTF-8') do |output_file|
  # Recursively find all files in the current directory and its subdirectories
  Find.find('.') do |path|
    # Skip directories
    next if File.directory?(path)

    # Skip files with ignored extensions
    next if ignored_extensions.any? { |ext| path.end_with?(ext) }

    # Include only files from specified directories
    next unless included_directories.any? { |dir| path.include?("/#{dir}/") }

    begin
      # Read the content of each file with UTF-8 encoding and append it to the output file
      File.open(path, 'r:UTF-8') do |file|
        output_file.puts(file.read)
        # Optionally, you can add a separator between files
        output_file.puts("\n--- End of #{path} ---\n")
      end
    rescue Encoding::InvalidByteSequenceError, Encoding::UndefinedConversionError
      # Handle files with encoding issues by reading them as binary and then encoding to UTF-8
      File.open(path, 'rb') do |file|
        output_file.puts(file.read.force_encoding('UTF-8').encode('UTF-8', invalid: :replace, undef: :replace, replace: '?'))
        output_file.puts("\n--- End of #{path} (with encoding adjustment) ---\n")
      end
    end
  end
end

puts 'All files from specified directories have been concatenated into resume.txt, ignoring specified file extensions.'
