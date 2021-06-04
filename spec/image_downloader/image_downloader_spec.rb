RSpec.describe ImageDownloader do
  context 'with file containing tow valid urls' do
    let(:url1) { 'https://examaple.com/1' }
    let(:url2) { 'http://examaple.com/2' }
    let(:content_type) { "image/jpg" }
    let(:response_headers) { { "Content-Type" => content_type } }
    let(:directory_name) { './imgs' }
    let(:file_name) { './example.txt' }

    before do
      f = File.open(file_name, 'w')
      f.write(url1 + ' ' + url2)
      f.close
      stub_request(:get, 'https://examaple.com/1 ').to_return(status: '200',
                                                              body: 'body',
                                                              headers: response_headers)
      stub_request(:get, 'http://examaple.com/2').to_return(status: '200',
                                                            body: 'body',
                                                            headers: response_headers)
    end

    after do
      FileUtils.rm_rf(Dir[directory_name])
      File.delete(file_name) if File.exists?(file_name)
    end

    it 'save two file on disk' do
      described_class.call([file_name, directory_name])
      expect(Dir.children(directory_name).size).to eq 2
    end
  end
end
