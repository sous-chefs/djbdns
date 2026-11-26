# frozen_string_literal: true

require 'shellwords'

provides :djbdns_install
unified_mode true

include Djbdns::Helpers

use '_partial/_common'

property :dnscache_uid, Integer, default: 9997
property :dnslog_uid, Integer, default: 9998
property :tinydns_uid, Integer, default: 9999

action_class do
  include Djbdns::Helpers
end

action :install do
  supervisor = %w(runit runsvdir runsvdir-start).find do |service_name|
    %w(/etc/systemd/system /usr/lib/systemd/system /lib/systemd/system).any? do |path|
      ::File.file?(::File.join(path, "#{service_name}.service"))
    end
  end

  if platform_family?('debian')
    package 'runit'
    service(supervisor || 'runit') { action [:enable, :start] }
  elsif supervisor
    service(supervisor) { action [:enable, :start] }
  else
    runit_archive = ::File.join(Chef::Config[:file_cache_path], 'runit-2.3.1.tar.gz')
    runit_source = ::File.join(Chef::Config[:file_cache_path], 'admin/runit-2.3.1/src')
    runit_tools = %w(chpst runsv runsvdir sv svlogd)
    runit_missing = runit_tools.any? { |tool| !::File.executable?("/usr/local/bin/#{tool}") }

    if runit_missing
      build_essential 'install compilation tools'

      remote_file runit_archive do
        source 'https://www.smarden.org/runit/runit-2.3.1.tar.gz'
        checksum '634f23c8c4d1d440043be0fe928ddf904626289e97bfe7c5826e93aaf2cc6fe9'
        action :create_if_missing
      end

      archive_file runit_archive do
        destination Chef::Config[:file_cache_path]
        overwrite true
        not_if { ::File.directory?(runit_source) }
      end

      execute 'build and install runit supervision tools' do
        working_tools = runit_tools.join(' ')
        command "make #{working_tools} && install -m 0755 #{working_tools} /usr/local/bin/"
        cwd runit_source
      end
    end

    service_root = runit_service_directory
    directory service_root do
      mode '0755'
      recursive true
    end

    systemd_unit 'djbdns-runit.service' do
      content(
        Unit: { Description: 'Runit service supervisor' },
        Service: {
          ExecStart: "/usr/local/bin/runsvdir -P #{service_root}",
          Environment: 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin',
          Restart: 'always',
        },
        Install: { WantedBy: 'multi-user.target' }
      )
      action [:create, :enable, :start]
    end
  end

  case new_resource.install_method
  when 'package'
    package new_resource.package_name do
      action :install
    end
  when 'source'
    bin_path = resolved_bin_dir
    unless bin_path.start_with?('/') && bin_path.end_with?('/bin')
      raise ArgumentError, 'The Djbdns source binary directory must be an absolute path ending in /bin'
    end

    tools_installed = Djbdns::Helpers::DJBDNS_BINARIES.all? { |binary| ::File.executable?(::File.join(bin_path, binary)) }
    unless tools_installed && ::File.file?('/etc/dnsroots.global')
      source_dir = ::File.join(Chef::Config[:file_cache_path], 'djbdns-1.05')

      remote_file "#{Chef::Config[:file_cache_path]}/djbdns-1.05.tar.gz" do
        source new_resource.source_url
        checksum new_resource.source_checksum if new_resource.source_checksum
        action :create
      end

      archive_file "#{Chef::Config[:file_cache_path]}/djbdns-1.05.tar.gz" do
        destination Chef::Config[:file_cache_path]
        overwrite true
        action :extract
      end

      file '/etc/dnsroots.global' do
        content lazy { ::File.read(::File.join(source_dir, 'dnsroots.global')) }
        owner 'root'
        group 'root'
        mode '0644'
        action :create_if_missing
      end
    end

    unless tools_installed
      build_essential 'install compilation tools'

      file ::File.join(source_dir, 'conf-cc') do
        content "gcc -O2 -std=gnu89 -include /usr/include/errno.h\n"
        owner 'root'
        group 'root'
        mode '0644'
      end

      file ::File.join(source_dir, 'conf-home') do
        content "#{::File.dirname(bin_path)}\n"
      end

      directory bin_path do
        recursive true
      end

      execute 'install_djbdns' do
        copy_binaries = ['install', '-m', '0755', *Djbdns::Helpers::DJBDNS_BINARIES, bin_path].shelljoin
        command "make && #{copy_binaries}"
        cwd source_dir
        action :run
      end
    end
  end

  {
    'dnscache' => new_resource.dnscache_uid,
    'dnslog' => new_resource.dnslog_uid,
    'tinydns' => new_resource.tinydns_uid,
  }.each do |username, uid|
    user username do
      uid uid
      gid nobody_group
      shell '/bin/false'
      home "/home/#{username}"
      system true
      manage_home true
    end
  end

  directory new_resource.base_dir do
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
  end
end

action :remove do
  case new_resource.install_method
  when 'package'
    package new_resource.package_name do
      action :remove
    end
  when 'source'
    Djbdns::Helpers::DJBDNS_BINARIES.each do |binary|
      file ::File.join(resolved_bin_dir, binary) do
        action :delete
      end
    end
  end
end
