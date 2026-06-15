control 'public-dnscache' do
  describe port(53) do
    its('protocols') { should include 'udp' }
  end

  describe command('/usr/bin/sv status public-dnscache') do
    its(:stdout) { should match(/^run:/) }
  end

  describe file('/etc/service/public-dnscache/root/ip/127') do
    it { should be_file }
  end

  describe file('/etc/service/public-dnscache/root/servers/example.test') do
    its(:content) { should match(/^127\.0\.0\.1$/) }
  end
end

control 'tinydns' do
  describe port(53) do
    its('addresses') { should include '127.0.0.1' }
    its('protocols') { should include 'udp' }
  end

  describe file('/etc/service/tinydns/root/data') do
    its(:content) { should match(/\.example\.test:127\.0\.0\.1:a:259200/) }
  end

  describe file('/etc/service/tinydns/root/data.cdb') do
    it { should be_file }
  end
end
