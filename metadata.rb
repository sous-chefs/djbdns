name              'djbdns'
maintainer        'Chef Software, Inc.'
maintainer_email  'cookbooks@chef.io'
license           'Apache-2.0'
description       'Installs djbdns and configures DNS services'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           '5.0.1'
recipe            'djbdns', 'Installs djbdns from package or source and creates users'
recipe            'djbdns::axfr', 'Sets up djbdns AXFR service'
recipe            'djbdns::cache', 'Sets up public dnscache service'
recipe            'djbdns::internal_server', 'Sets up internal TinyDNS'
recipe            'djbdns::server', 'Sets up external TinyDNS'

depends 'build-essential'
depends 'runit', '>= 1.6.0'

%w( ubuntu debian redhat centos scientific amazon oracle ).each do |os|
  supports os
end

source_url 'https://github.com/chef-cookbooks/djbdns'
issues_url 'https://github.com/chef-cookbooks/djbdns/issues'
chef_version '>= 12.5' if respond_to?(:chef_version)
