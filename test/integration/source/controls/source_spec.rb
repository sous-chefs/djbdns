control 'source-install' do
  describe file('/usr/local/bin/tinydns') do
    it { should be_file }
    it { should be_executable }
  end
end
