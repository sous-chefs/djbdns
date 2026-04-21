# frozen_string_literal: true

# calls tinydns-edit: usage: tinydns-edit data data.new add [ns|childns|host|alias|mx] domain a.b.c.d
# e.g., tinydns-edit data data.new add host tester2.int.housepub.org 10.13.37.79

provides :djbdns_rr
unified_mode true

property :fqdn, String, name_property: true
property :ip, String, required: true
property :type, String, default: 'host', equal_to: %w(alias alias6 childns host host6 mx ns)
property :cwd, String

default_action :add

action :add do
  type = new_resource.type
  fqdn = new_resource.fqdn
  ip = new_resource.ip
  cwd = new_resource.cwd || "#{node['djbdns']['tinydns_internal_dir']}/root"
  data_file = "#{cwd}/data"

  unless ::File.exist?(data_file) && IO.readlines(data_file).grep(/^[\.\+=]#{fqdn}:#{ip}/).length >= 1
    execute "./add-#{type} #{fqdn} #{ip}" do
      cwd cwd
      ignore_failure true
    end
  end
end
