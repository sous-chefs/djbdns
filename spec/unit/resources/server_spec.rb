# frozen_string_literal: true

require 'spec_helper'

describe 'djbdns_server' do
  step_into :djbdns_server
  platform 'ubuntu', '22.04'

  context 'with defaults' do
    recipe do
      node.override['runit']['sv_dir'] = '/etc/sv'
      node.override['runit']['service_dir'] = '/etc/service'
      djbdns_server 'tinydns' do
        domain 'example.test'
        manage_install false
      end
    end

    it do
      is_expected.to run_execute('/usr/local/bin/tinydns-conf tinydns dnslog /etc/djbdns/tinydns 127.0.0.1')
    end

    it { is_expected.to create_template('/etc/djbdns/tinydns/root/data') }
    it { is_expected.to render_file('/etc/djbdns/tinydns/root/data').with_content(/\.example\.test:127\.0\.0\.1:a:259200/) }
    it { is_expected.to create_link('/etc/sv/tinydns').with(to: '/etc/djbdns/tinydns') }
    it { is_expected.to enable_runit_service('tinydns') }
  end
end
