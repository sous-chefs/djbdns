# frozen_string_literal: true

control 'djbdns-source-cache-01' do
  impact 1.0
  title 'public dnscache service is running after source install'

  describe service('public-dnscache') do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(53) do
    its('protocols') { should include 'udp' }
  end

  describe command('host chef.io') do
    its(:stdout) { should match(/chef.io has address.*/) }
  end
end

control 'djbdns-source-tinydns-01' do
  impact 1.0
  title 'tinydns service is running after source install'

  describe service('tinydns') do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(53) do
    its('addresses') { should include '127.0.0.1' }
    its('protocols') { should include 'udp' }
  end

  describe file('/etc/djbdns/tinydns/root/data') do
    its(:content) { should match(/\.:127\.0\.0\.1:a:259200/) }
  end

  describe file('/etc/djbdns/tinydns/root/data.cdb') do
    it { should be_file }
  end
end
