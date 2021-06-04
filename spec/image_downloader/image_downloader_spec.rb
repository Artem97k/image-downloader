RSpec.describe ImageDownloader do
  context 'with file containing two valid urls' do
    let(:url1) { 'https://examaple.com/1' }
    let(:url2) { 'http://examaple.com/2' }
    let(:content_type) { "image/jpg" }
    let(:response_headers) { { "Content-Type" => content_type } }
    let(:directory_name) { 'imgs' }
    let(:file_name) { 'example.txt' }

    before do
      f = File.open(file_name, 'w')
      f.write(url1 + "\n" + url2)
      f.close
      stub_request(:get, 'https://examaple.com/1 ').to_return(status: 200,
                                                              body: 'body1',
                                                              headers: response_headers)
      stub_request(:get, 'http://examaple.com/2').to_return(status: 200,
                                                            body: 'body2',
                                                            headers: response_headers)
    end

    after do
      Dir.chdir('../')
      File.delete(file_name) if File.exists?(file_name)
      FileUtils.rm_rf(Dir[directory_name]) if File.directory?(directory_name)
    end

    it 'save two file on disk' do
      described_class.call([file_name, directory_name])
      expect(Dir.children('.').size).to eq 2
    end
  end

  context 'with file containing invalid urls' do
    let(:url1) { 'invalid' }
    let(:url2) { 'invalid2' }
    let(:directory_name) { 'imgs' }
    let(:file_name) { 'example.txt' }

    before do
      f = File.open(file_name, 'w')
      f.write(url1 + "\n" + url2)
      f.close
    end

    after do
      Dir.chdir('../')
      File.delete(file_name) if File.exists?(file_name)
      FileUtils.rm_rf(Dir[directory_name]) if File.directory?(directory_name)
    end

    it 'does not save files on  disk' do
      described_class.call([file_name, directory_name])
      expect(Dir.children('.').size).to eq 0
    end
  end
end
