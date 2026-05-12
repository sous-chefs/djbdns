# frozen_string_literal: true

require 'spec_helper'

describe 'djbdns_internal_server' do
  step_into :djbdns_internal_server
  platform 'ubuntu', '22.04'

  context 'with explicit records' do
    recipe do
      djbdns_internal_server 'tinydns-internal' do
        listen_ip '127.0.0.2'
        manage_install false
        records(
          'host' => [
            { 'web1.int.example.test' => '192.0.2.10' },
          ]
        )
      end
    end

    it do
      is_expected.to run_execute('/usr/local/bin/tinydns-conf tinydns dnslog /etc/djbdns/tinydns-internal 127.0.0.2')
    end

    it { is_expected.to create_file('/etc/djbdns/tinydns-internal/root/data') }
    it { is_expected.to create_systemd_unit('tinydns-internal.service') }
    it { is_expected.to enable_service('tinydns-internal') }
    it { is_expected.to start_service('tinydns-internal') }
  end

  context 'with template fallback' do
    recipe do
      djbdns_internal_server 'tinydns-internal' do
        manage_install false
        use_data_bag false
        zone_domain 'int.example.test'
        zone_ip '192.0.2.20'
      end
    end

    it { is_expected.to create_template('/etc/djbdns/tinydns-internal/root/data') }
    it { is_expected.to render_file('/etc/djbdns/tinydns-internal/root/data').with_content(/\.int\.example\.test:192\.0\.2\.20:a:259200/) }
  end

  context 'delete action' do
    recipe do
      djbdns_internal_server 'tinydns-internal' do
        manage_install false
        action :delete
      end
    end

    it { is_expected.to delete_systemd_unit('tinydns-internal.service') }
    it { is_expected.to delete_directory('/etc/djbdns/tinydns-internal') }
  end
end
