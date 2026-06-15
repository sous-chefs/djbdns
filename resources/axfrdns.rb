# frozen_string_literal: true

provides :djbdns_axfrdns
unified_mode true

include Djbdns::Helpers

use '_partial/_common'

property :service_name, String, name_property: true
property :directory, String, default: lazy { ::File.join(base_dir, service_name) }
property :tinydns_directory, String, default: lazy { ::File.join(base_dir, 'tinydns') }
property :ipaddress, String, default: '127.0.0.1'
property :axfrdns_uid, Integer, default: 9996

action_class do
  include Djbdns::Helpers
end

action :create do
  ensure_runit_defaults

  djbdns_install 'default' do
    install_method new_resource.install_method
    package_name new_resource.package_name
    bin_dir new_resource.bin_dir
    base_dir new_resource.base_dir
    source_url new_resource.source_url
    source_checksum new_resource.source_checksum
    action :install
  end

  user 'axfrdns' do
    uid new_resource.axfrdns_uid
    gid nobody_group
    shell '/bin/false'
    home '/home/axfrdns'
  end

  execute "#{resolved_bin_dir}/axfrdns-conf axfrdns dnslog #{new_resource.directory} #{new_resource.tinydns_directory} #{new_resource.ipaddress}" do
    not_if { ::File.directory?(new_resource.directory) }
  end

  directory new_resource.sv_dir do
    recursive true
  end

  link "#{new_resource.sv_dir}/#{new_resource.service_name}" do
    to new_resource.directory
  end

  runit_service new_resource.service_name do
    cookbook 'djbdns'
    env(
      'IP' => new_resource.ipaddress,
      'BIN_DIR' => resolved_bin_dir
    )
    action :enable
    not_if { runit_service_enabled?(new_resource.service_name) }
  end

  execute "start #{new_resource.service_name}" do
    command "/usr/bin/sv start #{new_resource.service_name}"
    not_if "/usr/bin/sv status #{new_resource.service_name} | grep '^run:'"
  end
end

action :delete do
  ensure_runit_defaults

  runit_service new_resource.service_name do
    cookbook 'djbdns'
    action [:stop, :disable]
  end

  link "#{new_resource.sv_dir}/#{new_resource.service_name}" do
    action :delete
  end

  directory new_resource.directory do
    recursive true
    action :delete
  end
end
