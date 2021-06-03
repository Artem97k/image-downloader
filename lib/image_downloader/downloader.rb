require 'net/http'
require 'date'
require 'concurrent-ruby'

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

    def initialize(urls, folder_path)
      @folder_path = folder_path
      @urls = urls
      @pool = Concurrent::FixedThreadPool.new(5)
      @responses = Concurrent::Array.new
    end

    def call
      get_images
      save_images
    end

    private

    def get_images
      @urls.each do |url|
        @pool.post { @responses << get_response(url) }
      end
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
