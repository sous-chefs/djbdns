# frozen_string_literal: true

apt_update 'update' if platform_family?('debian')

directory '/opt/djbdns' do
  mode '0750'
end

djbdns_install 'source' do
  install_method 'source'
  bin_dir '/opt/djbdns/bin'
end
