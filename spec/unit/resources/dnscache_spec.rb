# frozen_string_literal: true

require 'spec_helper'

describe 'djbdns_dnscache' do
  step_into :djbdns_dnscache
  platform 'ubuntu', '24.04'

  recipe do
    djbdns_dnscache 'public-dnscache' do
      ipaddress '127.0.0.1'
      allowed_networks ['127']
      resolved_domain 'example.test'
      resolved_reverse_domains ['0.in-addr.arpa']
    end
  end

  before do
    allow(File).to receive(:directory?).and_call_original
    allow(File).to receive(:directory?).with('/etc/djbdns/public-dnscache').and_return(false)
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with('/usr/local/bin/tinydns').and_return(true)
    stub_command("/usr/bin/sv status public-dnscache | grep '^run:'").and_return(false)
  end

  it { is_expected.to install_djbdns_install('default') }
  it { is_expected.to run_execute('/usr/local/bin/dnscache-conf dnscache dnslog /etc/djbdns/public-dnscache 127.0.0.1') }
  it { is_expected.to create_file('/etc/djbdns/public-dnscache/root/ip/127') }
  it { is_expected.to create_template('/etc/djbdns/public-dnscache/root/servers/example.test') }
  it { is_expected.to create_template('/etc/djbdns/public-dnscache/root/servers/0.in-addr.arpa') }
  it { is_expected.to run_execute('start public-dnscache') }
end
