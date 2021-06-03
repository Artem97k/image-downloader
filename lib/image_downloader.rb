require_relative 'image_downloader/url_extractor'
require_relative 'image_downloader/downloader'

module ImageDownloader
  class << self
    def call(args)
      file_name, folder_path = args
      urls = UrlExtractor.new(file_name).call
      Downloader.new(urls, folder_path).call
    end
  end
end
