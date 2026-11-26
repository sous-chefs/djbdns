control 'source-install' do
  describe directory('/opt/djbdns') do
    its('mode') { should cmp '0750' }
  end

  describe file('/opt/djbdns/bin/tinydns') do
    it { should be_file }
    it { should be_executable }
  end
end
