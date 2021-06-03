require 'net/http'
require 'date'

module ImageDownloader
  class Downloader
    MIME_TYPES = {
      "image/jpeg" => ".jpeg",
      "image/png" => ".png",
      "image/gif" => ".gif",
      "image/bmp" => ".bpm",
      "image/svg+xml" => ".svg",
      "image/webm" => ".webm"
    }.freeze

    def initialize(urls, directory_path)
      @directory_path = directory_path
      @urls = urls
    end

    def call
      get_images
      make_directory
      save_images
    end

    private

    def make_directory
      Dir.mkdir @directory_path unless File.directory? @directory_path
      Dir.chdir @directory_path
    rescue Errno::ENOENT
      puts 'Directory not found!'
    rescue Errno::EROFS
      puts 'Read-only  directory!'
    end

    def get_images
      threads = []
      mutex = Mutex.new
      responses = []
      @urls.each do |url|
        threads << Thread.new(url) do |url|
          response = get_response(url)
          mutex.synchronize { responses << response }
        end
      end
      @responses = responses.compact
      threads.each(&:join)
    end

    def get_response(url)
      url = URI(url)
      ssl = url.is_a? URI::HTTPS
      Net::HTTP.start(url.host, url.port, use_ssl: ssl) do |http|
        request = Net::HTTP::Get.new url
        http.request request
      end
    rescue URI::InvalidURIError
      puts 'Invalid URL found!'
    rescue Net::ReadTimeout, Net::OpenTimeout, SocketError, Errno::ECONNREFUSED
      puts 'Download error!'
    end

    def save_images
      @responses.each { |response| save_image(response) }
    end

    def save_image(response)
      return unless response.code == '200'

      body = response.body
      content_type = response['content-type']
      extension = MIME_TYPES[content_type]

      return if body.empty? || extension.nil?

      path = [@folder_path, DateTime.now.to_s, extension].join
      file = File.open(path, 'wb')
      file.write body
    rescue IOError
      puts 'Error writing to file!'
    rescue Errno::EPERM
      puts 'No permission to write!'
    ensure
      file.close unless file.nil?
    end
  end
end
