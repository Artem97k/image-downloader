RSpec.describe ImageDownloader do
  context 'with file containing two valid urls' do
    let(:url1) { 'https://example.com/1' }
    let(:url2) { 'http://example.com/2' }
    let(:content_type) { "image/jpg" }
    let(:response_headers) { { "Content-Type" => content_type } }
    let(:directory_name) { 'imgs' }
    let(:file_name) { 'example1.txt' }
    subject { Dir.children(directory_name).size }

    before do
      f = File.open(file_name, 'w')
      f.puts url1
      f.puts url2
      f.close
      stub_request(:get, url1).to_return(status: 200,
                                         body: 'body1',
                                         headers: response_headers)
      stub_request(:get, url2).to_return(status: 200,
                                         body: 'body2',
                                         headers: response_headers)
    end

    after do
      File.delete(file_name) if File.exist?(file_name)
      FileUtils.rm_rf(Dir[directory_name]) if File.directory?(directory_name)
    end

    it 'save two file on disk' do
      described_class.new([file_name, directory_name]).call
      expect(subject).to eq 2
    end
  end

  context 'with file containing invalid urls' do
    let(:url1) { 'invalid' }
    let(:url2) { 'invalid2' }
    let(:directory_name) { 'imgs' }
    let(:file_name) { 'example2.txt' }
    subject { Dir.children(directory_name).size }

    before do
      f = File.open(file_name, 'w')
      f.puts url1
      f.puts url2
      f.close
    end

    after do
      File.delete(file_name) if File.exist?(file_name)
      FileUtils.rm_rf(Dir[directory_name]) if File.directory?(directory_name)
    end

    it 'does not save files on  disk' do
      described_class.new([file_name, directory_name]).call
      expect(subject).to eq 0
    end
  end
end
