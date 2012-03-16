#
# Author:: Joshua Timberman (<joshua@opscode.com>)
# Cookbook Name:: djbdns
# Recipe:: internal_server
#
# Copyright 2009, Opscode, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
include_recipe "djbdns"

# Pull required configuration attributes
c_args = bag_or_node_args(%w(
  bin_dir
  tinydns_internal_dir
  tinydns_ipaddress
  service_type
  domain
))

Chef::Log.debug "Configuration args: #{c_args.inspect}"

execute "#{c_args[:bin_dir]}/tinydns-conf tinydns dnslog #{c_args[:tinydns_internal_dir]} #{c_args[:tinydns_ipaddress]}" do
  not_if { ::File.directory?(c_args[:tinydns_internal_dir]) }
end

execute "build-tinydns-internal-data" do
  cwd "#{c_args[:tinydns_internal_dir]}/root"
  command "make"
  action :nothing
end

begin
  dns = data_bag_item("djbdns", c_args[:domain].gsub(/\./, "_"))

  file "#{c_args[:tinydns_internal_dir]}/root/data" do
    action :create
  end

  %w{ ns host alias }.each do |type|
    dns[type].each do |record|
      record.each do |fqdn,ip|

        djbdns_rr fqdn do
          cwd "#{c_args[:tinydns_internal_dir]}/root"
          ip ip
          type type
          action :add
          notifies :run, "execute[build-tinydns-internal-data]"
        end

      end
    end
  end
rescue
  template "#{c_args[:tinydns_internal_dir]}/root/data" do
    source "tinydns-internal-data.erb"
    mode 0644
    notifies :run, resources("execute[build-tinydns-internal-data]")
  end
end

case c_args[:service_type]
when "runit"
  link "#{node[:runit][:sv_dir]}/tinydns-internal" do
    to c_args[:tinydns_internal_dir]
  end
  runit_service "tinydns-internal"
when "bluepill"
  template "#{node['bluepill']['conf_dir']}/tinydns-internal.pill" do
    source "tinydns-internal.pill.erb"
    mode 0644
  end
  bluepill_service "tinydns-internal" do
    action [:enable,:load,:start]
  end
when "daemontools"
  daemontools_service "tinydns-internal" do
    directory c_args[:tinydns_internal_dir]
    template false
    action [:enable,:start]
  end
end
