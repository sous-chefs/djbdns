# frozen_string_literal: true

require 'ipaddr'

provides :djbdns_rr

# calls tinydns-edit: usage: tinydns-edit data data.new add [ns|childns|host|alias|mx] domain a.b.c.d
# e.g., tinydns-edit data data.new add host tester2.int.housepub.org 10.13.37.79

unified_mode true

property :fqdn, String, name_property: true
property :ip, String, required: true
property :type, String, default: 'host', equal_to: %w(alias alias6 childns host host6 mx ns)
property :cwd, String, default: '/etc/djbdns/tinydns-internal/root'

action_class do
  def record_regex
    markers = { 'ns' => '.', 'childns' => '&', 'host' => '=', 'alias' => '+', 'mx' => '@', 'host6' => '6', 'alias6' => '3' }
    marker = markers.fetch(new_resource.type)
    address = if %w(host6 alias6).include?(new_resource.type)
                IPAddr.new(new_resource.ip).hton.unpack1('H*')
              else
                new_resource.ip
              end

    /^#{Regexp.escape(marker + new_resource.fqdn)}:#{Regexp.escape(address)}(?=:|$)/i
  end

  def record_present?
    ::File.exist?("#{new_resource.cwd}/data") &&
      ::File.readlines("#{new_resource.cwd}/data").grep(record_regex).any?
  end
end

action :add do
  execute "./add-#{new_resource.type} #{new_resource.fqdn} #{new_resource.ip}" do
    cwd new_resource.cwd
    ignore_failure true
    not_if { record_present? }
  end
end

action :remove do
  file "#{new_resource.cwd}/data" do
    content lazy { ::File.readlines(path).reject { |line| line.match?(record_regex) }.join }
    only_if { record_present? }
  end
end
