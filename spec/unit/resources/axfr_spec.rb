# frozen_string_literal: true

require 'spec_helper'

describe 'djbdns_axfr' do
  step_into :djbdns_axfr
  platform 'ubuntu', '22.04'

  context 'with defaults' do
    recipe do
      djbdns_axfr 'axfrdns' do
        manage_install false
      end
    end

    it { is_expected.to create_user('axfrdns').with(uid: 9996) }

    it do
      is_expected.to run_execute('/usr/local/bin/axfrdns-conf axfrdns dnslog /etc/djbdns/axfrdns /etc/djbdns/tinydns 127.0.0.1')
    end

    it { is_expected.to create_link('/etc/sv/axfrdns').with(to: '/etc/djbdns/axfrdns') }
    it { is_expected.to enable_runit_service('axfrdns') }
  end
end
