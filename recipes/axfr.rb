#
# Author:: Joshua Timberman (<joshua@chef.io>)
# Cookbook:: djbdns
# Recipe:: axfr
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

user 'axfrdns' do
  uid node['djbdns']['axfrdns_uid']
  gid node['platform_family'] == 'debian' ? 'nogroup' : 'nobody'
  shell '/bin/false'
  home '/home/axfrdns'
end

execute "#{node['djbdns']['bin_dir']}/axfrdns-conf axfrdns dnslog #{node['djbdns']['axfrdns_dir']} #{node['djbdns']['tinydns_dir']} #{node['djbdns']['axfrdns_ipaddress']}" do
  not_if { ::File.directory?(node['djbdns']['axfrdns_dir']) }
end

directory node['runit']['sv_dir'] do
  recursive true
end

link "#{node['runit']['sv_dir']}/axfrdns" do
  to node['djbdns']['axfrdns_dir']
end

runit_service 'axfrdns'
