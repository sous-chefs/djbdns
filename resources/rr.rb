# frozen_string_literal: true

# calls tinydns-edit: usage: tinydns-edit data data.new add [ns|childns|host|alias|mx] domain a.b.c.d
# e.g., tinydns-edit data data.new add host tester2.int.housepub.org 10.13.37.79

provides :djbdns_rr
unified_mode true

property :fqdn, String, name_property: true
property :ip, String, required: true
property :type, String, default: 'host', equal_to: %w(alias alias6 childns host host6 mx ns)
property :cwd, String, default: '/etc/djbdns/tinydns-internal/root'

default_action :add

action :add do
  unless record_present?
    execute "./add-#{new_resource.type} #{new_resource.fqdn} #{new_resource.ip}" do
      cwd new_resource.cwd
      ignore_failure true
    end
  end
end

action :delete do
  ruby_block "remove #{new_resource.fqdn} from tinydns data" do
    block do
      lines = ::File.readlines(data_file)
      ::File.write(data_file, lines.reject { |line| line.match?(record_pattern) }.join)
    end
    only_if { ::File.exist?(data_file) }
  end
end

action_class do
  def data_file
    ::File.join(new_resource.cwd, 'data')
  end

  def record_pattern
    /^[.+=]#{Regexp.escape(new_resource.fqdn)}:#{Regexp.escape(new_resource.ip)}/
  end

  def record_present?
    ::File.exist?(data_file) && ::File.readlines(data_file).grep(record_pattern).any?
  end
end
