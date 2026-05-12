# frozen_string_literal: true

apt_update 'update' if platform_family?('debian')

install_method = node.dig('djbdns', 'install_method')

djbdns_install 'default' do
  install_method install_method if install_method
end

djbdns_internal_server 'tinydns-internal' do
  manage_install false
  use_data_bag false
  zone_domain 'int.example.test'
  zone_ip '192.0.2.20'
  install_method install_method if install_method
end
