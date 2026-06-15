# frozen_string_literal: true

require 'spec_helper'

describe 'djbdns_tinydns' do
  step_into :djbdns_tinydns
  platform 'ubuntu', '24.04'

  recipe do
    djbdns_tinydns 'tinydns' do
      domain 'example.test'
      ipaddress '127.0.0.1'
    end
  end

  before do
    allow(File).to receive(:directory?).and_call_original
    allow(File).to receive(:directory?).with('/etc/djbdns/tinydns').and_return(false)
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with('/usr/local/bin/tinydns').and_return(true)
    stub_command("/usr/bin/sv status tinydns | grep '^run:'").and_return(false)
  end

  it { is_expected.to install_djbdns_install('default') }
  it { is_expected.to run_execute('/usr/local/bin/tinydns-conf tinydns dnslog /etc/djbdns/tinydns 127.0.0.1') }
  it { is_expected.to create_template('/etc/djbdns/tinydns/root/data').with(variables: { domain: 'example.test', ipaddress: '127.0.0.1' }) }
  it { is_expected.to create_link('/etc/sv/tinydns').with(to: '/etc/djbdns/tinydns') }
  it { is_expected.to run_execute('start tinydns') }

  it 'enables the runit service with BIN_DIR' do
    resource = chef_run.find_resource(:runit_service, 'tinydns')

    expect(resource.action).to eq([:enable])
    expect(resource.env['BIN_DIR']).to eq('/usr/local/bin')
  end
end
