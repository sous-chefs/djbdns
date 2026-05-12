# frozen_string_literal: true

require 'spec_helper'

describe 'djbdns_server' do
  step_into :djbdns_server
  platform 'ubuntu', '22.04'

  context 'with defaults' do
    recipe do
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
    it { is_expected.to create_systemd_unit('tinydns.service') }
    it { is_expected.to enable_service('tinydns') }
    it { is_expected.to start_service('tinydns') }
  end

  context 'delete action' do
    recipe do
      djbdns_server 'tinydns' do
        manage_install false
        action :delete
      end
    end

    it { is_expected.to delete_systemd_unit('tinydns.service') }
    it { is_expected.to delete_directory('/etc/djbdns/tinydns') }
  end
end
