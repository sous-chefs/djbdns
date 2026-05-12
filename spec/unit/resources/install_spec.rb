# frozen_string_literal: true

require 'spec_helper'

describe 'djbdns_install' do
  step_into :djbdns_install

  context 'with package install' do
    platform 'ubuntu', '16.04'

    recipe do
      djbdns_install 'default'
    end

    it { is_expected.to install_package('djbdns') }
    it { is_expected.to create_user('dnscache').with(uid: 9997) }
    it { is_expected.to create_user('dnslog').with(uid: 9998) }
    it { is_expected.to create_user('tinydns').with(uid: 9999) }
    it { is_expected.to create_directory('/etc/djbdns') }
  end

  context 'with source install' do
    platform 'ubuntu', '22.04'

    recipe do
      djbdns_install 'default'
    end

    it { is_expected.to create_remote_file('/tmp/djbdns-1.05.tar.gz') }
    it { is_expected.to install_package('tar') }
    it { is_expected.to run_bash('install_djbdns') }
    it { is_expected.to run_bash('install_djbdns').with_code(/#include <unistd\.h>/) }
  end

  context 'delete action' do
    platform 'ubuntu', '22.04'

    recipe do
      djbdns_install 'default' do
        action :delete
      end
    end

    it { is_expected.to delete_directory('/etc/djbdns') }
  end
end
