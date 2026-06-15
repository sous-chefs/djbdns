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
      allow(File).to receive(:exist?).with('/usr/lib/systemd/system/runit.service').and_return(true)
      allow(File).to receive(:exist?).with('/usr/bin/runsvchdir').and_return(true)
      allow(File).to receive(:directory?).and_call_original
      allow(File).to receive(:directory?).with('/etc/runit/runsvdir/default').and_return(true)
      stub_command('test "$(readlink /etc/runit/runsvdir/current 2>/dev/null)" = default').and_return(false)
    end

    it { is_expected.to install_package('runit') }
    it { is_expected.to enable_service('runit') }
    it { is_expected.to start_service('runit') }
    it { is_expected.to run_execute('runsvchdir default') }
    it { is_expected.to install_build_essential('install compilation tools') }
    it { is_expected.to create_remote_file("#{Chef::Config[:file_cache_path]}/djbdns-1.05.tar.gz") }
    it { is_expected.to extract_archive_file("#{Chef::Config[:file_cache_path]}/djbdns-1.05.tar.gz") }
    it { is_expected.to run_execute('install_djbdns') }
    it { is_expected.to create_user('dnscache').with(uid: 9997, system: true) }
    it { is_expected.to create_user('dnslog').with(uid: 9998, system: true) }
    it { is_expected.to create_user('tinydns').with(uid: 9999, system: true) }
    it { is_expected.to create_directory('/etc/djbdns') }
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
