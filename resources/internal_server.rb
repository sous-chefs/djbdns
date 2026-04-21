# frozen_string_literal: true

provides :djbdns_internal_server
unified_mode true

property :service_name, String, name_property: true
property :manage_install, [true, false], default: true, desired_state: false
property :install_method, String, equal_to: %w(package source),
                                  default: lazy { platform?('ubuntu') && node['platform_version'].to_f < 18.04 ? 'package' : 'source' }
property :package_name, String, default: 'djbdns'
property :source_url, String, default: 'https://cr.yp.to/djbdns/djbdns-1.05.tar.gz'
property :bin_dir, String,
                   default: lazy { install_method == 'package' ? '/usr/bin' : '/usr/local/bin' }
property :service_dir, String, default: '/etc/djbdns/tinydns-internal'
property :sv_dir, String, default: '/etc/sv'
property :service_link_dir, String, default: '/etc/service'
property :sv_bin, String, default: lazy { platform_family?('debian') ? '/usr/bin/sv' : '/sbin/sv' }
property :listen_ip, String, default: '127.0.0.1'
property :zone_domain, String, default: lazy { node['domain'] || 'domain.local' }
property :zone_ip, String, default: '127.0.0.1'
property :data_template_source, String, default: 'tinydns-internal-data.erb'
property :use_data_bag, [true, false], default: true
property :data_bag_name, String, default: 'djbdns'
property :data_bag_item_id, [String, NilClass], default: lazy { zone_domain.tr('.', '_') }
property :records, Hash, default: {}
property :dnscache_uid, Integer, default: 9997
property :dnslog_uid, Integer, default: 9998
property :tinydns_uid, Integer, default: 9999

default_action :create

action :create do
  if new_resource.manage_install
    djbdns_install "install for #{new_resource.service_name}" do
      install_method new_resource.install_method
      package_name new_resource.package_name
      source_url new_resource.source_url
      bin_dir new_resource.bin_dir
      dnscache_uid new_resource.dnscache_uid
      dnslog_uid new_resource.dnslog_uid
      tinydns_uid new_resource.tinydns_uid
      action :create
    end
  end

  execute "#{new_resource.bin_dir}/tinydns-conf tinydns dnslog #{new_resource.service_dir} #{new_resource.listen_ip}" do
    not_if { ::File.directory?(new_resource.service_dir) }
  end

  execute "build-#{new_resource.service_name}-data" do
    cwd "#{new_resource.service_dir}/root"
    command 'make'
    action :nothing
  end

  if effective_records.empty?
    template "#{new_resource.service_dir}/root/data" do
      source new_resource.data_template_source
      mode '0644'
      variables(
        zone_domain: new_resource.zone_domain,
        zone_ip: new_resource.zone_ip
      )
      notifies :run, "execute[build-#{new_resource.service_name}-data]"
    end
  else
    file "#{new_resource.service_dir}/root/data" do
      action :create
    end

    effective_records.each do |record_type, record_entries|
      Array(record_entries).each do |record|
        record.each do |fqdn, ip|
          djbdns_rr fqdn do
            cwd "#{new_resource.service_dir}/root"
            ip ip
            type record_type
            action :add
            notifies :run, "execute[build-#{new_resource.service_name}-data]"
          end
        end
      end
    end
  end

  directory new_resource.sv_dir do
    recursive true
  end

  link "#{new_resource.sv_dir}/#{new_resource.service_name}" do
    to new_resource.service_dir
  end

  runit_service new_resource.service_name do
    sv_dir new_resource.sv_dir
    service_dir new_resource.service_link_dir
    sv_bin new_resource.sv_bin
    env(
      'ROOT' => "#{new_resource.service_dir}/root",
      'IP' => new_resource.listen_ip
    )
    options(bin_dir: new_resource.bin_dir)
  end
end

action_class do
  def effective_records
    return @effective_records if defined?(@effective_records)

    @effective_records =
      if new_resource.records.empty?
        load_data_bag_records
      else
        normalize_records(new_resource.records)
      end
  end

  def load_data_bag_records
    return {} unless new_resource.use_data_bag
    return {} if new_resource.data_bag_item_id.nil? || new_resource.data_bag_item_id.empty?

    normalize_records(data_bag_item(new_resource.data_bag_name, new_resource.data_bag_item_id))
  rescue StandardError
    {}
  end

  def normalize_records(record_source)
    Array(record_source).each_with_object({}) do |(record_type, entries), normalized|
      next unless entries

      normalized[record_type.to_s] = Array(entries)
    end
  end
end
