RSpec.describe Downloader do
  context 'with valid directory path' do
    let(:directory_path) { 'imgs' }
    subject { File.directory?(directory_path) }

    after do
      FileUtils.rm_rf(Dir[directory_path]) if File.directory?(directory_path)
    end

    it 'creates directory' do
      described_class.new directory_path
      sleep 0.1
      expect(subject).to eq true
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
      sleep 0.1
      expect(subject).to eq false
    end
  end
end
