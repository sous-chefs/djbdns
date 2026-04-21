apt_update 'update' if platform_family?('debian')

djbdns_install 'default' do
  install_method node['djbdns']['install_method'] if node['djbdns']['install_method']
end

djbdns_server 'tinydns' do
  manage_install false
  install_method node['djbdns']['install_method'] if node['djbdns']['install_method']
end

djbdns_cache 'public-dnscache' do
  manage_install false
  install_method node['djbdns']['install_method'] if node['djbdns']['install_method']
end

# for the `host` command used in the tests
package 'bind-utils' if platform_family?('rhel', 'fedora')
package 'dnsutils' if platform_family?('debian')
