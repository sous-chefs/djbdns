# frozen_string_literal: true

provides :djbdns_tinydns
unified_mode true

include Djbdns::Helpers

use '_partial/_common'

property :service_name, String, name_property: true
property :directory, String, default: lazy { ::File.join(base_dir, service_name) }
property :ipaddress, String, default: '127.0.0.1'
property :domain, String, default: lazy { default_domain }
property :internal, [true, false], default: false
property :data_bag, [String, nil]
property :data_bag_item_name, [String, nil]

action_class do
  include Djbdns::Helpers

  def data_template
    new_resource.internal ? 'tinydns-internal-data.erb' : 'tinydns-data.erb'
  end

  def data_bag_records
    return unless new_resource.data_bag

    item_name = new_resource.data_bag_item_name || new_resource.domain.tr('.', '_')
    data_bag_item(new_resource.data_bag, item_name)
  rescue
    nil
  end
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

  execute "#{resolved_bin_dir}/tinydns-conf tinydns dnslog #{new_resource.directory} #{new_resource.ipaddress}" do
    not_if { ::File.directory?(new_resource.directory) }
  end

  execute "build-#{new_resource.service_name}-data" do
    cwd "#{new_resource.directory}/root"
    command 'make'
    action :nothing
  end

  records = data_bag_records

  if records
    file "#{new_resource.directory}/root/data" do
      action :create
      owner 'root'
      group 'root'
      mode '0644'
    end

    %w(ns host alias).each do |type|
      Array(records[type]).each do |record|
        record.each do |fqdn, ip|
          djbdns_rr fqdn do
            cwd "#{new_resource.directory}/root"
            ip ip
            type type
            action :add
            notifies :run, "execute[build-#{new_resource.service_name}-data]"
          end
        end
      end
    end
  else
    template "#{new_resource.directory}/root/data" do
      source data_template
      cookbook 'djbdns'
      variables(domain: new_resource.domain, ipaddress: new_resource.ipaddress)
      owner 'root'
      group 'root'
      mode '0644'
      notifies :run, "execute[build-#{new_resource.service_name}-data]"
    end
  end

  directory new_resource.sv_dir do
    recursive true
  end

  link "#{new_resource.sv_dir}/#{new_resource.service_name}" do
    to new_resource.directory
  end

  runit_service new_resource.service_name do
    cookbook 'djbdns'
    env service_env(new_resource.directory, new_resource.ipaddress, resolved_bin_dir)
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
