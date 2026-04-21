# frozen_string_literal: true

provides :djbdns_install
unified_mode true

property :instance_name, String, name_property: true
property :install_method, String, equal_to: %w(package source),
                                  default: lazy { platform?('ubuntu') && node['platform_version'].to_f < 18.04 ? 'package' : 'source' }
property :package_name, String, default: 'djbdns'
property :source_url, String, default: 'https://cr.yp.to/djbdns/djbdns-1.05.tar.gz'
property :bin_dir, String,
                   default: lazy { install_method == 'package' ? '/usr/bin' : '/usr/local/bin' }
property :dnscache_uid, Integer, default: 9997
property :dnslog_uid, Integer, default: 9998
property :tinydns_uid, Integer, default: 9999

default_action :create

action :create do
  include_recipe 'runit'

  case new_resource.install_method
  when 'package'
    package new_resource.package_name do
      action :install
    end
  when 'source'
    build_essential 'install compilation tools'

    remote_file source_archive_path do
      source new_resource.source_url
      mode '0644'
      action :create
      not_if { ::File.exist?(djbdns_binary) }
    end

    bash 'install_djbdns' do
      cwd '/tmp'
      code <<~EOH
        tar xzvf #{source_archive_path}
        cd #{source_extract_dir}
        echo gcc -O2 -include /usr/include/errno.h > conf-cc
        make setup check
      EOH
      not_if { ::File.exist?(djbdns_binary) }
    end
  end

  {
    'dnscache' => new_resource.dnscache_uid,
    'dnslog' => new_resource.dnslog_uid,
    'tinydns' => new_resource.tinydns_uid,
  }.each do |account, uid|
    user account do
      uid uid
      gid service_group
      shell '/bin/false'
      home "/home/#{account}"
      system true
      manage_home true
    end
  end

  directory '/etc/djbdns'
end

action_class do
  def service_group
    platform_family?('debian') ? 'nogroup' : 'nobody'
  end

  def source_archive_path
    ::File.join('/tmp', ::File.basename(new_resource.source_url))
  end

  def source_extract_dir
    archive = ::File.basename(new_resource.source_url, '.tar.gz')
    ::File.join('/tmp', archive)
  end

  def djbdns_binary
    ::File.join(new_resource.bin_dir, 'tinydns')
  end
end
