require_relative '../../../kitchen/data/spec_helper'

describe 'public-dnscache' do
  describe port(53) do
    it { should be_listening.with('udp') }
  end

  describe command('host chef.io') do
    its(:stdout) { should match(/chef.io has address.*/) }
  end
end

describe 'tinydns' do
  describe port(53) do
    it { should be_listening.on('127.0.0.1').with('udp') }
  end

  describe file('/etc/service/tinydns/root/data') do
    its(:content) { should match(/.vagrantup.com:127.0.0.1:a:259200/) }
  end

  describe file('/etc/service/tinydns/root/data.cdb') do
    it { should be_file }
  end
end
