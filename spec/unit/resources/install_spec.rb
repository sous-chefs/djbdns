# frozen_string_literal: true

require 'spec_helper'

describe 'djbdns_install' do
  step_into :djbdns_install
  platform 'ubuntu', '24.04'

  context 'with source install' do
    recipe do
      djbdns_install 'default' do
        install_method 'source'
      end
    end

    before do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with('/usr/local/bin/tinydns').and_return(false)
    end

    it { is_expected.to install_package('runit') }
    it { is_expected.to enable_service('runit') }
    it { is_expected.to start_service('runit') }
    it { is_expected.to install_build_essential('install compilation tools') }
    it { is_expected.to create_remote_file("#{Chef::Config[:file_cache_path]}/djbdns-1.05.tar.gz") }
    it { is_expected.to extract_archive_file("#{Chef::Config[:file_cache_path]}/djbdns-1.05.tar.gz") }
    it { is_expected.to create_file_if_missing('/etc/dnsroots.global') }
    it { is_expected.to run_execute('install_djbdns') }
    it { is_expected.to create_user('dnscache').with(uid: 9997, system: true) }
    it { is_expected.to create_user('dnslog').with(uid: 9998, system: true) }
    it { is_expected.to create_user('tinydns').with(uid: 9999, system: true) }
    it { is_expected.to create_directory('/etc/djbdns') }
  end

  context 'without a packaged runit supervisor on AlmaLinux' do
    platform 'almalinux', '9'

    recipe { djbdns_install 'default' }

    it { is_expected.to run_execute('build and install runit supervision tools') }
    it { is_expected.to start_systemd_unit('djbdns-runit.service') }

    context 'when a package already provides the supervisor' do
      before do
        allow(File).to receive(:file?).and_call_original
        allow(File).to receive(:file?).with('/usr/lib/systemd/system/runsvdir-start.service').and_return(true)
      end

      it { is_expected.to start_service('runsvdir-start') }
      it { is_expected.not_to create_systemd_unit('djbdns-runit.service') }
    end
  end

  context 'with package install' do
    recipe do
      djbdns_install 'default' do
        install_method 'package'
        package_name 'dbndns'
      end
    end

    it { is_expected.to install_package('dbndns') }
  end
end
