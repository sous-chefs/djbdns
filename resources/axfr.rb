# frozen_string_literal: true

provides :djbdns_axfr
unified_mode true

use '_partial/_install'

property :service_name, String, name_property: true
property :manage_install, [true, false], default: true, desired_state: false
property :service_dir, String, default: '/etc/djbdns/axfrdns'
property :listen_ip, String, default: '127.0.0.1'
property :tinydns_dir, String, default: '/etc/djbdns/tinydns'
property :axfrdns_uid, Integer, default: 9996

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

  manage_djbdns_service(
    service_name: new_resource.service_name,
    exec_start: "/bin/sh -c 'exec tcpserver -vDRHl0 -x #{new_resource.service_dir}/tcp.cdb -- #{new_resource.listen_ip} 53 #{new_resource.bin_dir}/axfrdns'",
    working_directory: new_resource.service_dir,
    environment: {
      'ROOT' => "#{new_resource.tinydns_dir}/root",
      'IP' => new_resource.listen_ip,
      'UID' => new_resource.axfrdns_uid,
      'GID' => service_group_gid,
    },
    limit_data: '300000'
  )
end

action :delete do
  remove_djbdns_service(
    service_name: new_resource.service_name,
    service_dir: new_resource.service_dir
  )

  user 'axfrdns' do
    action :remove
  end
end

action_class do
  include Djbdns::ServiceUnitHelpers

  def service_group
    platform_family?('debian') ? 'nogroup' : 'nobody'
  end
end
