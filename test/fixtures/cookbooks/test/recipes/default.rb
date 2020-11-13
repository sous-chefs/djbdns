apt_update 'update' if platform_family?('debian')

include_recipe 'djbdns::server'
include_recipe 'djbdns::cache'

# for the `host` command used in the tests
package 'bind-utils' if platform_family?('rhel', 'fedora')
package 'dnsutils' if platform_family?('debian')
