#
# Cookbook:: djbdns
# Recipe:: default
# Author:: Joshua Timberman (<joshua@chef.io>)
# Author:: Joshua Sierles (<joshua@37signals.com>)
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

default['djbdns']['tinydns_ipaddress']          = '127.0.0.1'
default['djbdns']['tinydns_internal_ipaddress'] = '127.0.0.1'
default['djbdns']['public_dnscache_ipaddress']  = node['ipaddress']
default['djbdns']['axfrdns_ipaddress']          = '127.0.0.1'

default['djbdns']['axfrdns_uid']  = 9996
default['djbdns']['dnscache_uid'] = 9997
default['djbdns']['dnslog_uid']   = 9998
default['djbdns']['tinydns_uid']  = 9999

default['djbdns']['public_dnscache_allowed_networks'] = [node['ipaddress'].split('.')[0, 2].join('.')]
default['djbdns']['tinydns_internal_resolved_domain'] = node['domain'] || 'domain.local'
# see Locally Served DNS Zones: http://tools.ietf.org/html/rfc6303
default['djbdns']['tinydns_internal_resolved_reverse_domains'] = [
  '10.in-addr.arpa', '16.172.in-addr.arpa', '17.172.in-addr.arpa',
  '18.172.in-addr.arpa', '19.172.in-addr.arpa', '20.172.in-addr.arpa',
  '21.172.in-addr.arpa', '22.172.in-addr.arpa', '23.172.in-addr.arpa',
  '24.172.in-addr.arpa', '25.172.in-addr.arpa', '26.172.in-addr.arpa',
  '27.172.in-addr.arpa', '28.172.in-addr.arpa', '29.172.in-addr.arpa',
  '30.172.in-addr.arpa', '31.172.in-addr.arpa', '168.192.in-addr.arpa',
  '0.in-addr.arpa', '127.in-addr.arpa', '254.169.in-addr.arpa',
  '2.0.192.in-addr.arpa', '100.51.198.in-addr.arpa', '113.0.203.in-addr.arpa',
  '255.255.255.255.in-addr.arpa'
]

default['djbdns']['public_dnscache_cachesize'] = '1000000'
default['djbdns']['public_dnscache_datalimit'] = '3000000'

default['djbdns']['axfrdns_dir']          = '/etc/djbdns/axfrdns'
default['djbdns']['tinydns_dir']          = '/etc/djbdns/tinydns'
default['djbdns']['tinydns_internal_dir'] = '/etc/djbdns/tinydns-internal'
default['djbdns']['public_dnscache_dir']  = '/etc/djbdns/public-dnscache'

default['djbdns']['install_method'] = node['platform'] == 'ubuntu' ? 'package' : 'source'

default['djbdns']['package_name'] = 'djbdns'

default['djbdns']['bin_dir'] = if node['djbdns']['install_method'] == 'package'
                                 '/usr/bin'
                               else
                                 '/usr/local/bin'
                               end
