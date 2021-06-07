RSpec.describe Downloader do
  context 'with valid directory path' do
    let(:directory_path) { 'imgs' }
    subject { File.directory?(directory_path) }

    after do
      FileUtils.rm_rf(Dir[directory_path]) if File.directory?(directory_path)
    end

    it 'creates directory' do
      described_class.new directory_path
      expect(subject).to eq true
    end
  end

  context 'with valid directory path and url' do
    let(:directory_path) { 'imgs' }
    let(:url) { 'https://example.com/1' }
    let(:content_type) { "image/jpg" }
    let(:response_headers) { { "Content-Type" => content_type } }
    subject { described_class.new directory_path }

    before do
      stub_request(:get, url).to_return(status: 200,
                                        body: 'body1',
                                        headers: response_headers)
    end

    after do
      FileUtils.rm_rf(Dir[directory_path]) if File.directory?(directory_path)
    end

    it 'creates directory with image in it' do
      subject.call(url)
      subject.shutdown
      expect(Dir.children(directory_path).size).to eq 1
    end
  end

  context 'with invalid directory path' do
    let(:directory_path) { '/invalid/imgs' }
    subject { File.directory?(directory_path) }

    after do
      FileUtils.rm_rf(Dir[directory_path]) if File.directory?(directory_path)
    end

    it 'does not create directory' do
      described_class.new directory_path
      expect(subject).to eq false
    end
  end
end
