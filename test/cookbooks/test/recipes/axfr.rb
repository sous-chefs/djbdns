apt_update 'update' if platform_family?('debian')

djbdns_install 'default' do
  install_method node['djbdns']['install_method'] if node['djbdns']['install_method']
end

djbdns_server 'tinydns' do
  manage_install false
  install_method node['djbdns']['install_method'] if node['djbdns']['install_method']
end

djbdns_axfr 'axfrdns' do
  manage_install false
  install_method node['djbdns']['install_method'] if node['djbdns']['install_method']
end
