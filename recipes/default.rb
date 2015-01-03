#
# Cookbook Name:: djbdns
# Recipe:: default
# Author:: Joshua Timberman (<joshua@opscode.com>)
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

include_recipe node['djbdns']['service_type']

case node['djbdns']['install_method']
when 'package'

  package node['djbdns']['package_name'] do
    action :install
  end

when "aur"

  pacman_aur "djbdns" do
    action [:build, :install]
  end

when "source"

  include_recipe "build-essential"
  include_recipe "ucspi-tcp"

  bash "install_djbdns" do
    user "root"
    cwd "/tmp"
    code <<-EOH
    (cd /tmp; wget http://cr.yp.to/djbdns/djbdns-1.05.tar.gz)
    (cd /tmp; tar xzvf djbdns-1.05.tar.gz)
    (cd /tmp/djbdns-1.05; perl -pi -e 's/extern int errno;/\#include <errno.h>/' error.h)
    (cd /tmp/djbdns-1.05; make setup check)
    EOH
    not_if { ::File.exist?("#{node['djbdns']['bin_dir']}/tinydns") }
  end

end

user 'dnscache' do
  uid node['djbdns']['dnscache_uid']
  gid case node['platform_family']
      when 'debian' then 'nogroup'
      else 'nobody'
  end
  shell '/bin/false'
  home '/home/dnscache'
  system true
  supports :manage_home => true
end

user 'dnslog' do
  uid node['djbdns']['dnslog_uid']
  gid case node['platform_family']
      when 'debian' then 'nogroup'
      else 'nobody'
  end
  shell '/bin/false'
  home '/home/dnslog'
  system true
  supports :manage_home => true
end

user 'tinydns' do
  uid node['djbdns']['tinydns_uid']
  gid case node['platform_family']
      when 'debian' then 'nogroup'
      else 'nobody'
  end
  shell '/bin/false'
  home '/home/tinydns'
  system true
  supports :manage_home => true
end

directory '/etc/djbdns'
