# frozen_string_literal: true

provides :djbdns_axfrdns
unified_mode true

include Djbdns::Helpers

use '_partial/_common'

property :service_name, String, name_property: true
property :directory, String, default: lazy { ::File.join(base_dir, service_name) }
property :tinydns_directory, String, default: lazy { ::File.join(base_dir, 'tinydns') }
property :ipaddress, String, default: '127.0.0.1'
property :axfrdns_uid, Integer, default: 9996

action_class do
  include Djbdns::Helpers
end

action :create do
  node.default['runit'] = {} unless node['runit']

  djbdns_install 'default' do
    install_method new_resource.install_method
    package_name new_resource.package_name
    bin_dir new_resource.bin_dir
    base_dir new_resource.base_dir
    source_url new_resource.source_url
    source_checksum new_resource.source_checksum
    action :install
  end

  if platform_family?('debian')
    package 'ucspi-tcp'
  elsif !%w(/usr/local/bin /usr/bin /bin).any? { |path| %w(tcpserver tcprules).all? { |tool| ::File.executable?(::File.join(path, tool)) } }
    build_essential 'install compilation tools'
    archive = ::File.join(Chef::Config[:file_cache_path], 'ucspi-tcp-0.88.tar.gz')
    source_dir = ::File.join(Chef::Config[:file_cache_path], 'ucspi-tcp-0.88')

    remote_file archive do
      source 'https://cr.yp.to/ucspi-tcp/ucspi-tcp-0.88.tar.gz'
      checksum '4a0615cab74886f5b4f7e8fd32933a07b955536a3476d74ea087a3ea66a23e9c'
      action :create_if_missing
      not_if { ::File.executable?('/usr/local/bin/tcpserver') && ::File.executable?('/usr/local/bin/tcprules') }
    end

    archive_file archive do
      destination Chef::Config[:file_cache_path]
      overwrite true
      not_if { ::File.directory?(source_dir) }
      only_if { ::File.file?(archive) }
    end

    file ::File.join(source_dir, 'conf-cc') do
      content "gcc -O2 -include errno.h\n"
      only_if { ::File.directory?(source_dir) }
    end

    execute 'build AXFR TCP tools' do
      command 'make tcpserver tcprules && install -m 0755 tcpserver tcprules /usr/local/bin/'
      cwd source_dir
      not_if { ::File.executable?('/usr/local/bin/tcpserver') && ::File.executable?('/usr/local/bin/tcprules') }
    end
  end

  user 'axfrdns' do
    uid new_resource.axfrdns_uid
    gid nobody_group
    shell '/bin/false'
    home '/home/axfrdns'
  end

  execute "#{resolved_bin_dir}/axfrdns-conf axfrdns dnslog #{new_resource.directory} #{new_resource.tinydns_directory} #{new_resource.ipaddress}" do
    not_if { ::File.directory?(new_resource.directory) }
  end

  execute "compile #{new_resource.service_name} TCP rules" do
    cwd new_resource.directory
    command 'make tcp.cdb'
    not_if do
      rules_db = ::File.join(new_resource.directory, 'tcp.cdb')
      ::File.file?(rules_db) && ::File.mtime(rules_db) >= ::File.mtime(::File.join(new_resource.directory, 'tcp'))
    end
  end

  directory new_resource.sv_dir do
    recursive true
  end

  link "#{new_resource.sv_dir}/#{new_resource.service_name}" do
    to new_resource.directory
  end

  runit_service new_resource.service_name do
    cookbook 'djbdns'
    sv_bin runit_sv_binary
    sv_dir new_resource.sv_dir
    service_dir runit_service_directory
    run_template_name('axfrdns')
    log_template_name('axfrdns')
    env(
      'ROOT' => ::File.join(new_resource.tinydns_directory, 'root'),
      'IP' => new_resource.ipaddress,
      'BIN_DIR' => resolved_bin_dir
    )
    action [runit_service_enabled?(new_resource.service_name) ? :create : :enable, :start]
  end
end

action :delete do
  node.default['runit'] = {} unless node['runit']

  runit_service new_resource.service_name do
    cookbook 'djbdns'
    sv_bin runit_sv_binary
    sv_dir new_resource.sv_dir
    service_dir runit_service_directory
    action [:stop, :disable]
    only_if { runit_service_enabled?(new_resource.service_name) && ::File.executable?(runit_sv_binary) }
  end

  link "#{new_resource.sv_dir}/#{new_resource.service_name}" do
    action :delete
  end

  directory new_resource.directory do
    recursive true
    action :delete
  end
end
