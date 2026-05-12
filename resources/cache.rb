# frozen_string_literal: true

provides :djbdns_cache
unified_mode true

use '_partial/_install'

property :service_name, String, name_property: true
property :manage_install, [true, false], default: true, desired_state: false
property :service_dir, String, default: '/etc/djbdns/public-dnscache'
property :listen_ip, String, default: lazy { node['ipaddress'] }
property :allowed_networks, Array,
                            default: lazy { [node['ipaddress'].split('.')[0, 2].join('.')] },
                            coerce: proc { |value| Array(value) }
property :resolved_domain, String, default: lazy { node['domain'] || 'domain.local' }
property :resolved_reverse_domains, Array,
                                    default: lazy {
                                      %w(
                                        10.in-addr.arpa
                                        16.172.in-addr.arpa
                                        17.172.in-addr.arpa
                                        18.172.in-addr.arpa
                                        19.172.in-addr.arpa
                                        20.172.in-addr.arpa
                                        21.172.in-addr.arpa
                                        22.172.in-addr.arpa
                                        23.172.in-addr.arpa
                                        24.172.in-addr.arpa
                                        25.172.in-addr.arpa
                                        26.172.in-addr.arpa
                                        27.172.in-addr.arpa
                                        28.172.in-addr.arpa
                                        29.172.in-addr.arpa
                                        30.172.in-addr.arpa
                                        31.172.in-addr.arpa
                                        168.192.in-addr.arpa
                                        0.in-addr.arpa
                                        127.in-addr.arpa
                                        254.169.in-addr.arpa
                                        2.0.192.in-addr.arpa
                                        100.51.198.in-addr.arpa
                                        113.0.203.in-addr.arpa
                                        255.255.255.255.in-addr.arpa
                                      )
                                    },
                                    coerce: proc { |value| Array(value) }
property :cache_size, String, default: '1000000'
property :data_limit, String, default: '3000000'

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

  execute "#{new_resource.service_name}_update" do
    cwd new_resource.service_dir
    command "#{new_resource.bin_dir}/dnsip `#{new_resource.bin_dir}/dnsqr ns . | awk '/answer:/ { print \\$5 ; }' | sort` > root/servers/@"
    action :nothing
  end

  execute "#{new_resource.bin_dir}/dnscache-conf dnscache dnslog #{new_resource.service_dir} #{new_resource.listen_ip}" do
    not_if { ::File.directory?(new_resource.service_dir) }
    notifies :run, "execute[#{new_resource.service_name}_update]"
  end

  manage_djbdns_service(
    service_name: new_resource.service_name,
    exec_start: "#{new_resource.bin_dir}/dnscache",
    working_directory: new_resource.service_dir,
    environment: {
      'ROOT' => "#{new_resource.service_dir}/root",
      'IPSEND' => new_resource.listen_ip,
      'IP' => new_resource.listen_ip,
      'UID' => new_resource.dnscache_uid,
      'GID' => service_group_gid,
      'CACHESIZE' => new_resource.cache_size,
    },
    limit_data: new_resource.data_limit,
    limit_nofile: 250,
    standard_input: "file:#{new_resource.service_dir}/seed"
  )

  new_resource.allowed_networks.each do |net|
    file "#{new_resource.service_dir}/root/ip/#{net}" do
      mode '0644'
    end
  end

  template "#{new_resource.service_dir}/root/servers/#{new_resource.resolved_domain}" do
    cookbook 'djbdns'
    source 'dnscache-servers.erb'
    mode '0644'
  end

  new_resource.resolved_reverse_domains.each do |reverse_domain|
    template "#{new_resource.service_dir}/root/servers/#{reverse_domain}" do
      cookbook 'djbdns'
      source 'dnscache-servers.erb'
      mode '0644'
    end
  end
end

action :delete do
  remove_djbdns_service(
    service_name: new_resource.service_name,
    service_dir: new_resource.service_dir
  )
end

action_class do
  include Djbdns::ServiceUnitHelpers
end
