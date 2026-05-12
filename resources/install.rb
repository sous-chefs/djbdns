# frozen_string_literal: true

provides :djbdns_install
unified_mode true

use '_partial/_install'

property :instance_name, String, name_property: true

default_action :create

action :create do
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

action :delete do
  package new_resource.package_name do
    action :remove
    only_if { new_resource.install_method == 'package' }
  end

  directory '/etc/djbdns' do
    recursive true
    action :delete
  end
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
