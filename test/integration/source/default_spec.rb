control 'public-dnscache' do
  describe port(53) do
    its('protocols') { should include 'udp' }
  end

  describe command('host chef.io') do
    its(:stdout) { should match(/chef.io has address.*/) }
  end
end

control 'tinydns' do
  describe port(53) do
    its('addresses') { should include '127.0.0.1' }
    its('protocols') { should include 'udp' }
  end

  describe file('/etc/service/tinydns/root/data') do
    its(:content) { should match(/.test.local:127.0.0.1:a:259200/) }
  end

  describe file('/etc/service/tinydns/root/data.cdb') do
    it { should be_file }
  end
end
