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

djbdns_axfr 'axfrdns' do
  manage_install false
  install_method install_method if install_method
end
