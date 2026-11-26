# frozen_string_literal: true

property :install_method, String, default: lazy { default_install_method }, equal_to: %w(package source)
property :package_name, String, default: 'djbdns'
property :bin_dir, [String, nil], default: nil
property :base_dir, String, default: '/etc/djbdns'
property :sv_dir, String, default: '/etc/sv'
property :source_url, String, default: 'https://cr.yp.to/djbdns/djbdns-1.05.tar.gz'
property :source_checksum, [String, nil], default: nil
