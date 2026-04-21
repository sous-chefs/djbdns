#
# Author:: Joshua Timberman (<joshua@chef.io>)
# Author:: Joshua Sierles (<joshua@37signals.com>)
# Cookbook:: djbdns
# Recipe:: cache
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

djbdns_cache 'public-dnscache' do
  install_method node['djbdns']['install_method']
  package_name node['djbdns']['package_name']
  bin_dir node['djbdns']['bin_dir']
  service_dir node['djbdns']['public_dnscache_dir']
  listen_ip node['djbdns']['public_dnscache_ipaddress']
  allowed_networks node['djbdns']['public_dnscache_allowed_networks']
  resolved_domain node['djbdns']['tinydns_internal_resolved_domain']
  resolved_reverse_domains Array(node['djbdns']['tinydns_internal_resolved_reverse_domains'])
  cache_size node['djbdns']['public_dnscache_cachesize']
  data_limit node['djbdns']['public_dnscache_datalimit']
  dnscache_uid node['djbdns']['dnscache_uid']
  dnslog_uid node['djbdns']['dnslog_uid']
  tinydns_uid node['djbdns']['tinydns_uid']
end
