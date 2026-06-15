# frozen_string_literal: true

provides :djbdns_rr
unified_mode true

# calls tinydns-edit: usage: tinydns-edit data data.new add [ns|childns|host|alias|mx] domain a.b.c.d
# e.g., tinydns-edit data data.new add host tester2.int.housepub.org 10.13.37.79

property :fqdn, String, name_property: true
property :ip, String, required: true
property :type, String, default: 'host', equal_to: %w(alias alias6 childns host host6 mx ns)
property :cwd, String, default: '/etc/djbdns/tinydns-internal/root'

action_class do
  def record_regex
    /^[.+=@&C]#{Regexp.escape(new_resource.fqdn)}:#{Regexp.escape(new_resource.ip)}/
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
  ruby_block "remove #{new_resource.type} record #{new_resource.fqdn}" do
    block do
      data_file = "#{new_resource.cwd}/data"
      lines = ::File.readlines(data_file)
      ::File.write(data_file, lines.reject { |line| line.match?(record_regex) }.join)
    end
    only_if { record_present? }
  end
end
