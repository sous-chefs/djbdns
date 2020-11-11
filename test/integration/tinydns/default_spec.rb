host_ip = interface('eth0').ipv4_addresses.first

control 'public-dnscache' do
  describe port(53) do
    its('protocols') { should include 'udp' }
  end

  describe command "dig @#{host_ip} chef.io" do
    its(:stdout) { should match(/^chef\.io\..*IN\s+A/) }
  end
end

control 'tinydns' do
  describe port(53) do
    its('addresses') { should include '127.0.0.1' }
    its('protocols') { should include 'udp' }
  end

  describe file('/etc/service/tinydns/root/data') do
    its(:content) { should match(/\.:127\.0\.0\.1:a:259200/) }
  end

  describe file('/etc/service/tinydns/root/data.cdb') do
    it { should be_file }
  end
end
