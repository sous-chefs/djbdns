# frozen_string_literal: true

provides :djbdns_axfr
unified_mode true

property :service_name, String, name_property: true
property :manage_install, [true, false], default: true, desired_state: false
property :install_method, String, equal_to: %w(package source),
                                  default: lazy { platform?('ubuntu') && node['platform_version'].to_f < 18.04 ? 'package' : 'source' }
property :package_name, String, default: 'djbdns'
property :source_url, String, default: 'https://cr.yp.to/djbdns/djbdns-1.05.tar.gz'
property :bin_dir, String,
                   default: lazy { install_method == 'package' ? '/usr/bin' : '/usr/local/bin' }
property :service_dir, String, default: '/etc/djbdns/axfrdns'
property :sv_dir, String, default: '/etc/sv'
property :service_link_dir, String, default: '/etc/service'
property :sv_bin, String, default: lazy { platform_family?('debian') ? '/usr/bin/sv' : '/sbin/sv' }
property :listen_ip, String, default: '127.0.0.1'
property :tinydns_dir, String, default: '/etc/djbdns/tinydns'
property :axfrdns_uid, Integer, default: 9996
property :dnscache_uid, Integer, default: 9997
property :dnslog_uid, Integer, default: 9998
property :tinydns_uid, Integer, default: 9999

default_action :create

action :create do
  if new_resource.manage_install
    djbdns_install "install for #{new_resource.service_name}" do
      install_method new_resource.install_method
      package_name new_resource.package_name
      source_url new_resource.source_url
      bin_dir new_resource.bin_dir
      dnscache_uid new_resource.dnscache_uid
      dnslog_uid new_resource.dnslog_uid
      tinydns_uid new_resource.tinydns_uid
      action :create
    end
  end

  user 'axfrdns' do
    uid new_resource.axfrdns_uid
    gid service_group
    shell '/bin/false'
    home '/home/axfrdns'
  end

  execute "#{new_resource.bin_dir}/axfrdns-conf axfrdns dnslog #{new_resource.service_dir} #{new_resource.tinydns_dir} #{new_resource.listen_ip}" do
    not_if { ::File.directory?(new_resource.service_dir) }
  end

  directory new_resource.sv_dir do
    recursive true
  end

  link "#{new_resource.sv_dir}/#{new_resource.service_name}" do
    to new_resource.service_dir
  end

  runit_service new_resource.service_name do
    sv_dir new_resource.sv_dir
    service_dir new_resource.service_link_dir
    sv_bin new_resource.sv_bin
    options(bin_dir: new_resource.bin_dir)
  end
end

action_class do
  def service_group
    platform_family?('debian') ? 'nogroup' : 'nobody'
  end
end
