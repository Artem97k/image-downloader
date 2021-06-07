require 'net/http'
require 'date'
require 'digest'
require 'concurrent'

class Downloader
  attr_accessor :directory_path

  MIME_TYPES = {
    "image/jpeg" => ".jpeg",
    "image/jpg" => ".jpg",
    "image/webp" => ".webp",
    "image/png" => ".png",
    "image/gif" => ".gif",
    "image/bmp" => ".bpm",
    "image/svg+xml" => ".svg",
    "image/webm" => ".webm"
  }.freeze

  def initialize(directory_path)
    @directory_path = directory_path
    @pool = Concurrent::FixedThreadPool.new(4)
    make_directory
  end

  def call(url)
    @pool.post(url) do |url|
      fetch_image(url)
    end
  end

  def shutdown
    @pool.shutdown
  end

  def make_directory
    Dir.mkdir directory_path unless File.directory? directory_path
  rescue Errno::ENOENT
    puts 'Directory not found!'
  rescue Errno::EROFS
    puts 'Read-only  directory!'
  end

  private

  def fetch_image(url)
    url = URI(url)
    ssl = url.is_a? URI::HTTPS
    response = Net::HTTP.start(url.host, url.port, use_ssl: ssl) do |http|
      request = Net::HTTP::Get.new url
      http.request request
    end
    save_image(response, url)
  rescue URI::InvalidURIError
    puts 'Invalid URL found!'
  rescue Net::ReadTimeout, Net::OpenTimeout, SocketError, Errno::ECONNREFUSED
    puts 'Download error!'
  end

  def save_image(response, url)
    return unless response.code == '200'

    body = response.body
    content_type = response['content-type']
    extension = MIME_TYPES[content_type]

    return if body.empty? || extension.nil?

    date = DateTime.now
    digest = Digest::MD5.hexdigest(url.to_s)
    path = "#{directory_path}/#{date}-#{digest}-#{extension}"
    file = File.open(path, 'wb')
    file.write body
    file.close
  rescue IOError
    puts 'Error writing to file!'
  rescue Errno::EPERM
    puts 'No permission to write!'
  end
end
