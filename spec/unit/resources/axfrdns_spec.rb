# frozen_string_literal: true

require 'spec_helper'

describe 'djbdns_axfrdns' do
  step_into :djbdns_axfrdns
  platform 'ubuntu', '24.04'

  recipe do
    djbdns_axfrdns 'axfrdns' do
      ipaddress '127.0.0.1'
    end
  end

  before do
    allow(File).to receive(:directory?).and_call_original
    allow(File).to receive(:directory?).with('/etc/djbdns/axfrdns').and_return(false)
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with('/usr/local/bin/tinydns').and_return(true)
    stub_command("/usr/bin/sv status axfrdns | grep '^run:'").and_return(false)
  end

  it { is_expected.to install_djbdns_install('default') }
  it { is_expected.to create_user('axfrdns').with(uid: 9996) }
  it { is_expected.to run_execute('/usr/local/bin/axfrdns-conf axfrdns dnslog /etc/djbdns/axfrdns /etc/djbdns/tinydns 127.0.0.1') }
  it { is_expected.to create_link('/etc/sv/axfrdns').with(to: '/etc/djbdns/axfrdns') }
  it { is_expected.to run_execute('start axfrdns') }
end
