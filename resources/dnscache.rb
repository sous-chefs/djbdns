# frozen_string_literal: true

provides :djbdns_dnscache
unified_mode true

include Djbdns::Helpers

use '_partial/_common'

property :service_name, String, name_property: true
property :directory, String, default: lazy { ::File.join(base_dir, service_name) }
property :ipaddress, String, default: lazy { node['ipaddress'] || '127.0.0.1' }
property :allowed_networks, Array, default: lazy { default_allowed_networks }
property :resolved_domain, String, default: lazy { default_domain }
property :resolved_reverse_domains, Array, default: Djbdns::Helpers::REVERSE_DOMAINS
property :cachesize, String, default: '1000000'
property :datalimit, String, default: '3000000'

action_class do
  include Djbdns::Helpers
end

action :create do
  node.default['runit'] = {} unless node['runit']

  djbdns_install 'default' do
    install_method new_resource.install_method
    package_name new_resource.package_name
    bin_dir new_resource.bin_dir
    base_dir new_resource.base_dir
    source_url new_resource.source_url
    source_checksum new_resource.source_checksum
    action :install
  end

  execute "#{new_resource.service_name}_update" do
    cwd new_resource.directory
    command "#{resolved_bin_dir}/dnsip `#{resolved_bin_dir}/dnsqr ns . | awk '/answer:/ { print $5 ; }' | sort` > root/servers/@"
    action :nothing
  end

  execute "#{resolved_bin_dir}/dnscache-conf dnscache dnslog #{new_resource.directory} #{new_resource.ipaddress}" do
    not_if { ::File.directory?(new_resource.directory) }
    notifies :run, "execute[#{new_resource.service_name}_update]"
  end

  directory new_resource.sv_dir do
    recursive true
  end

  link "#{new_resource.sv_dir}/#{new_resource.service_name}" do
    to new_resource.directory
  end

  runit_service new_resource.service_name do
    cookbook 'djbdns'
    sv_bin runit_sv_binary
    sv_dir new_resource.sv_dir
    service_dir runit_service_directory
    run_template_name('public-dnscache')
    log_template_name('public-dnscache')
    env({
          'ROOT' => "#{new_resource.directory}/root",
          'IPSEND' => new_resource.ipaddress,
          'IP' => new_resource.ipaddress,
          'CACHESIZE' => new_resource.cachesize,
          'DATALIMIT' => new_resource.datalimit,
          'BIN_DIR' => resolved_bin_dir,
        })
    action [runit_service_enabled?(new_resource.service_name) ? :create : :enable, :start]
  end

  new_resource.allowed_networks.each do |network|
    file "#{new_resource.directory}/root/ip/#{network}" do
      mode '0644'
    end
  end

  ([new_resource.resolved_domain] + new_resource.resolved_reverse_domains).each do |domain|
    template "#{new_resource.directory}/root/servers/#{domain}" do
      source 'dnscache-servers.erb'
      cookbook 'djbdns'
      owner 'root'
      group 'root'
      mode '0644'
    end
  end
end

action :delete do
  node.default['runit'] = {} unless node['runit']

  runit_service new_resource.service_name do
    cookbook 'djbdns'
    sv_bin runit_sv_binary
    sv_dir new_resource.sv_dir
    service_dir runit_service_directory
    action [:stop, :disable]
    only_if { runit_service_enabled?(new_resource.service_name) && ::File.executable?(runit_sv_binary) }
  end

  link "#{new_resource.sv_dir}/#{new_resource.service_name}" do
    action :delete
  end

  directory new_resource.directory do
    recursive true
    action :delete
  end
end
