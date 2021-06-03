module ImageDownloader
  class UrlExtractor
    SEPARATOR = /\s+/
    URL_REGEXP = %r{^(http|https):\/\/\w+\.[a-z]{2,5}.+}

    def initialize(file_name)
      @file_name = file_name
    end

    def call
      read_file && extract_urls
    end

    private

    def read_file
      file = File.open(@file_name, 'r')
      @string = file.read
      file.close
      @string
    rescue Errno::ENOENT
      puts 'No such file or directory!'
    rescue StandardError
      puts 'Unexpected error!'
    end

    def extract_urls
      urls = @string.strip.split(SEPARATOR).uniq
      return puts 'Empty file!' if urls.empty?

      urls.filter! { |url| url.match?(URL_REGEXP) }
      return puts 'No valid URLs!' if urls.empty?

      urls
    end
  end
end
