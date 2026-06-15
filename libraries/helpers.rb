# frozen_string_literal: true

module Djbdns
  module Helpers
    REVERSE_DOMAINS = %w(
      10.in-addr.arpa 16.172.in-addr.arpa 17.172.in-addr.arpa
      18.172.in-addr.arpa 19.172.in-addr.arpa 20.172.in-addr.arpa
      21.172.in-addr.arpa 22.172.in-addr.arpa 23.172.in-addr.arpa
      24.172.in-addr.arpa 25.172.in-addr.arpa 26.172.in-addr.arpa
      27.172.in-addr.arpa 28.172.in-addr.arpa 29.172.in-addr.arpa
      30.172.in-addr.arpa 31.172.in-addr.arpa 168.192.in-addr.arpa
      0.in-addr.arpa 127.in-addr.arpa 254.169.in-addr.arpa
      2.0.192.in-addr.arpa 100.51.198.in-addr.arpa
      113.0.203.in-addr.arpa 255.255.255.255.in-addr.arpa
    ).freeze unless const_defined?(:REVERSE_DOMAINS)

    DJBDNS_BINARIES = %w(
      add-alias add-childns add-host add-mx add-ns axfr-get axfrdns
      axfrdns-conf dnscache dnscache-conf dnsfilter dnsip dnsipq dnsname
      dnsq dnsqr dnstrace rbldns rbldns-conf tinydns tinydns-conf
      tinydns-data tinydns-edit walldns walldns-conf
    ).freeze unless const_defined?(:DJBDNS_BINARIES)

    def default_install_method
      platform?('ubuntu') && node['platform_version'].to_f < 18.04 ? 'package' : 'source'
    end

    def resolved_bin_dir
      new_resource.bin_dir || (new_resource.install_method == 'package' ? '/usr/bin' : '/usr/local/bin')
    end

    def nobody_group
      platform_family?('debian') ? 'nogroup' : 'nobody'
    end

    def default_allowed_networks
      ipaddress = node['ipaddress'] || '127.0.0.1'
      [ipaddress.split('.')[0, 2].join('.')]
    end

    def default_domain
      node['domain'] || 'domain.local'
    end

    def service_env(base_dir, ipaddress, bin_dir = nil)
      {
        'ROOT' => "#{base_dir}/root",
        'IP' => ipaddress,
      }.tap { |env| env['BIN_DIR'] = bin_dir if bin_dir }
    end

    def ensure_runit_defaults
      node.default['runit']['sv_dir'] = '/etc/sv'
      node.default['runit']['service_dir'] = '/etc/service'
    end

    def runit_service_link(service_name)
      if ::File.directory?('/etc/runit/runsvdir/default')
        "/etc/runit/runsvdir/default/#{service_name}"
      else
        "/etc/service/#{service_name}"
      end
    end

    def runit_service_enabled?(service_name)
      ::File.exist?("/etc/service/#{service_name}") || ::File.exist?("/etc/runit/runsvdir/default/#{service_name}")
    end
  end
end
