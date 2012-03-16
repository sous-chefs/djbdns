#
# Author:: Joshua Timberman (<joshua@opscode.com>)
# Cookbook Name:: djbdns
# Recipe:: server
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
  tinydns_dir
  tinydns_ipaddress
  service_type
))

Chef::Log.debug "Configuration args: #{c_args.inspect}"

execute "#{c_args[:bin_dir]}/tinydns-conf tinydns dnslog #{c_args[:tinydns_dir]} #{c_args[:tinydns_ipaddress]}" do
  not_if { ::File.directory?(c_args[:tinydns_dir]) }
end

execute "build-tinydns-data" do
  cwd "#{c_args[:tinydns_dir]}/root"
  command "make"
  action :nothing
end

template "#{c_args[:tinydns_dir]}/root/data" do
  source "tinydns-data.erb"
  mode 0644
  notifies :run, resources("execute[build-tinydns-data]")
end

case c_args[:service_type]
when "runit"
  link "#{node[:runit][:sv_dir]}/tinydns" do
    to c_args[:tinydns_dir]
  end
  runit_service "tinydns"
when "bluepill"
  template "#{node['bluepill']['conf_dir']}/tinydns.pill" do
    source "tinydns.pill.erb"
    mode 0644
  end
  bluepill_service "tinydns" do
    action [:enable,:load,:start]
  end
when "daemontools"
  daemontools_service "tinydns" do
    directory c_args[:tinydns_dir]
    template false
    action [:enable,:start]
  end
end
