# frozen_string_literal: true

provides :djbdns_cache
unified_mode true

property :service_name, String, name_property: true
property :manage_install, [true, false], default: true, desired_state: false
property :install_method, String, equal_to: %w(package source),
                                  default: lazy { platform?('ubuntu') && node['platform_version'].to_f < 18.04 ? 'package' : 'source' }
property :package_name, String, default: 'djbdns'
property :source_url, String, default: 'https://cr.yp.to/djbdns/djbdns-1.05.tar.gz'
property :bin_dir, String,
                   default: lazy { install_method == 'package' ? '/usr/bin' : '/usr/local/bin' }
property :service_dir, String, default: '/etc/djbdns/public-dnscache'
property :sv_dir, String, default: '/etc/sv'
property :service_link_dir, String, default: '/etc/service'
property :sv_bin, String, default: lazy { platform_family?('debian') ? '/usr/bin/sv' : '/sbin/sv' }
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

  execute "#{new_resource.service_name}_update" do
    cwd new_resource.service_dir
    command "#{new_resource.bin_dir}/dnsip `#{new_resource.bin_dir}/dnsqr ns . | awk '/answer:/ { print \\$5 ; }' | sort` > root/servers/@"
    action :nothing
  end

  execute "#{new_resource.bin_dir}/dnscache-conf dnscache dnslog #{new_resource.service_dir} #{new_resource.listen_ip}" do
    not_if { ::File.directory?(new_resource.service_dir) }
    notifies :run, "execute[#{new_resource.service_name}_update]"
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
      'IPSEND' => new_resource.listen_ip,
      'IP' => new_resource.listen_ip,
      'CACHESIZE' => new_resource.cache_size,
      'DATALIMIT' => new_resource.data_limit
    )
    options(bin_dir: new_resource.bin_dir)
  end

  new_resource.allowed_networks.each do |net|
    file "#{new_resource.service_dir}/root/ip/#{net}" do
      mode '0644'
    end
  end

  template "#{new_resource.service_dir}/root/servers/#{new_resource.resolved_domain}" do
    source 'dnscache-servers.erb'
    mode '0644'
  end

  new_resource.resolved_reverse_domains.each do |reverse_domain|
    template "#{new_resource.service_dir}/root/servers/#{reverse_domain}" do
      source 'dnscache-servers.erb'
      mode '0644'
    end
  end
end
