require_relative 'image_downloader/url_extractor'
require_relative 'image_downloader/downloader'

module ImageDownloader
  class << self
    def call(args)
      file_name, directory_path = args
      if file_name.nil? || directory_path.nil?
        return puts 'File and folder name are required!'
      end
      urls = UrlExtractor.new(file_name).call
      Downloader.new(urls, directory_path).call
    end
  end
end
