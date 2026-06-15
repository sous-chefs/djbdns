# frozen_string_literal: true

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
  package 'runit' do
    action :install
  end

  service 'runit' do
    action [:enable, :start]
    only_if { ::File.exist?('/usr/lib/systemd/system/runit.service') || ::File.exist?('/lib/systemd/system/runit.service') }
  end

  execute 'runsvchdir default' do
    command 'runsvchdir default'
    only_if { ::File.exist?('/usr/bin/runsvchdir') && ::File.directory?('/etc/runit/runsvdir/default') }
    not_if 'test "$(readlink /etc/runit/runsvdir/current 2>/dev/null)" = default'
  end

  case new_resource.install_method
  when 'package'
    package new_resource.package_name do
      action :install
    end
  when 'source'
    build_essential 'install compilation tools'

    remote_file "#{Chef::Config[:file_cache_path]}/djbdns-1.05.tar.gz" do
      source new_resource.source_url
      checksum new_resource.source_checksum if new_resource.source_checksum
      action :create
    end

    archive_file "#{Chef::Config[:file_cache_path]}/djbdns-1.05.tar.gz" do
      destination Chef::Config[:file_cache_path]
      overwrite true
      action :extract
      not_if { ::File.exist?("#{resolved_bin_dir}/tinydns") }
    end

    file "#{Chef::Config[:file_cache_path]}/djbdns-1.05/conf-cc" do
      content "gcc -O2 -include /usr/include/errno.h\n"
      owner 'root'
      group 'root'
      mode '0644'
      not_if { ::File.exist?("#{resolved_bin_dir}/tinydns") }
    end

    execute 'install_djbdns' do
      command 'make setup check'
      cwd "#{Chef::Config[:file_cache_path]}/djbdns-1.05"
      action :run
      not_if { ::File.exist?("#{resolved_bin_dir}/tinydns") }
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
