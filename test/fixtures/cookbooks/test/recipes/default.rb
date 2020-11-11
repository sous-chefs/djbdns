apt_update 'update' if platform_family?('debian')

include_recipe 'djbdns::server'
include_recipe 'djbdns::cache'

file '/etc/resolv.conf' do
  manage_symlink_source true
  content "nameserver #{node['ipaddress']}"
end

# for the `host` command used in the tests
package 'bind-utils' if platform_family?('rhel', 'fedora')
package 'bind9-host' if platform_family?('debian')
