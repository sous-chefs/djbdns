# frozen_string_literal: true

provides :djbdns_server
unified_mode true

use '_partial/_install'

property :service_name, String, name_property: true
property :manage_install, [true, false], default: true, desired_state: false
property :service_dir, String, default: '/etc/djbdns/tinydns'
property :listen_ip, String, default: '127.0.0.1'
property :domain, [String, NilClass], default: lazy { node['domain'] }
property :data_template_source, String, default: 'tinydns-data.erb'

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

  execute "#{new_resource.bin_dir}/tinydns-conf tinydns dnslog #{new_resource.service_dir} #{new_resource.listen_ip}" do
    not_if { ::File.directory?(new_resource.service_dir) }
  end

  execute "build-#{new_resource.service_name}-data" do
    cwd "#{new_resource.service_dir}/root"
    command 'make'
    action :nothing
  end

  template "#{new_resource.service_dir}/root/data" do
    cookbook 'djbdns'
    source new_resource.data_template_source
    mode '0644'
    variables(
      domain: new_resource.domain,
      tinydns_ipaddress: new_resource.listen_ip
    )
    notifies :run, "execute[build-#{new_resource.service_name}-data]"
  end

  manage_djbdns_service(
    service_name: new_resource.service_name,
    exec_start: "#{new_resource.bin_dir}/tinydns",
    working_directory: new_resource.service_dir,
    environment: {
      'ROOT' => "#{new_resource.service_dir}/root",
      'IP' => new_resource.listen_ip,
      'UID' => new_resource.tinydns_uid,
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
end

action_class do
  include Djbdns::ServiceUnitHelpers
end
