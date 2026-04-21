# frozen_string_literal: true

require 'spec_helper'

describe 'djbdns_cache' do
  step_into :djbdns_cache
  platform 'ubuntu', '22.04'

  context 'with defaults' do
    recipe do
      node.override['runit']['sv_dir'] = '/etc/sv'
      node.override['runit']['service_dir'] = '/etc/service'
      djbdns_cache 'public-dnscache' do
        listen_ip '10.0.2.15'
        manage_install false
        resolved_domain 'domain.local'
      end
    end

    it do
      is_expected.to run_execute('/usr/local/bin/dnscache-conf dnscache dnslog /etc/djbdns/public-dnscache 10.0.2.15')
    end

    it { is_expected.to create_link('/etc/sv/public-dnscache').with(to: '/etc/djbdns/public-dnscache') }
    it { is_expected.to enable_runit_service('public-dnscache') }
    it { is_expected.to create_file('/etc/djbdns/public-dnscache/root/ip/10.0') }
    it { is_expected.to create_template('/etc/djbdns/public-dnscache/root/servers/domain.local') }
    it { is_expected.to create_template('/etc/djbdns/public-dnscache/root/servers/127.in-addr.arpa') }
  end
end
