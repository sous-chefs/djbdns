# frozen_string_literal: true

apt_update 'update' if platform_family?('debian')

djbdns_tinydns 'tinydns' do
  domain 'example.test'
  ipaddress '127.0.0.1'
  action :create
end

djbdns_dnscache 'public-dnscache' do
  ipaddress node['ipaddress']
  allowed_networks ['127', node['ipaddress'].split('.')[0, 2].join('.')]
  resolved_domain 'example.test'
  action :create
end

package 'bind-utils' if platform_family?('rhel', 'fedora', 'amazon')
package 'dnsutils' if platform_family?('debian')
