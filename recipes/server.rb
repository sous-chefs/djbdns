#
# Author:: Joshua Timberman (<joshua@chef.io>)
# Cookbook:: djbdns
# Recipe:: server
#
# Copyright:: 2009-2019, Chef Software, Inc
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

djbdns_server 'tinydns' do
  install_method node['djbdns']['install_method']
  package_name node['djbdns']['package_name']
  bin_dir node['djbdns']['bin_dir']
  service_dir node['djbdns']['tinydns_dir']
  listen_ip node['djbdns']['tinydns_ipaddress']
  domain node['domain']
  dnscache_uid node['djbdns']['dnscache_uid']
  dnslog_uid node['djbdns']['dnslog_uid']
  tinydns_uid node['djbdns']['tinydns_uid']
end
