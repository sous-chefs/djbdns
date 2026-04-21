apt_update 'update' if platform_family?('debian')

djbdns_install 'default' do
  install_method node['djbdns']['install_method'] if node['djbdns']['install_method']
end

djbdns_internal_server 'tinydns-internal' do
  manage_install false
  use_data_bag false
  zone_domain 'int.example.test'
  zone_ip '192.0.2.20'
  install_method node['djbdns']['install_method'] if node['djbdns']['install_method']
end
