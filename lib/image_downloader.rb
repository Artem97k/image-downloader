require_relative 'downloader'

class ImageDownloader
  attr_accessor :file_name, :directory_path

  URL_REGEXP = %r{^(http|https):\/\/[^.]+\.[^.]+}

  def initialize(args)
    @file_name, @directory_path = args
  end

  def call
    if file_name.nil? || directory_path.nil?
      return puts 'File and folder name are required!'
    end
    downloader = Downloader.new(directory_path)
    each_file_line do |url|
      downloader.call(url)
    end
    downloader.shutdown
  end

  private

  def each_file_line
    File.foreach(file_name).each do |line|
      line.strip!
      next unless line.match?(URL_REGEXP)

      yield line
    end
  rescue Errno::ENOENT
    puts 'No such file or directory!'
  rescue StandardError
    puts 'Unexpected error!'
  end
end
