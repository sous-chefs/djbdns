#
# Author:: Joshua Timberman (<joshua@chef.io>)
# Cookbook:: djbdns
# Recipe:: server
#
# Copyright:: 2009-2016, Chef Software, Inc
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

include_recipe 'djbdns::default'

execute "#{node['djbdns']['bin_dir']}/tinydns-conf tinydns dnslog #{node['djbdns']['tinydns_dir']} #{node['djbdns']['tinydns_ipaddress']}" do
  not_if { ::File.directory?(node['djbdns']['tinydns_dir']) }
end

execute 'build-tinydns-data' do
  cwd "#{node['djbdns']['tinydns_dir']}/root"
  command 'make'
  action :nothing
end

template "#{node['djbdns']['tinydns_dir']}/root/data" do
  source 'tinydns-data.erb'
  mode '0644'
  notifies :run, 'execute[build-tinydns-data]'
end

link "#{node['runit']['sv_dir']}/tinydns" do
  to node['djbdns']['tinydns_dir']
end

runit_service 'tinydns'
