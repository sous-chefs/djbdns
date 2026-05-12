# frozen_string_literal: true

apt_update 'update' if platform_family?('debian')

install_method = node.dig('djbdns', 'install_method')

djbdns_install 'default' do
  install_method install_method if install_method
end

djbdns_server 'tinydns' do
  manage_install false
  install_method install_method if install_method
end

djbdns_cache 'public-dnscache' do
  manage_install false
  install_method install_method if install_method
end

# for the `host` command used in the tests
package 'bind-utils' if platform_family?('rhel', 'fedora')
package 'dnsutils' if platform_family?('debian')
