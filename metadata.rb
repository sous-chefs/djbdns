name              'djbdns'
maintainer        'Chef Software, Inc.'
maintainer_email  'cookbooks@chef.io'
license           'Apache 2.0'
description       'Installs djbdns and configures DNS services'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           '1.2.0'
recipe            'djbdns', 'Installs djbdns from package or source and creates users'
recipe            'djbdns::axfr', 'Sets up djbdns AXFR service'
recipe            'djbdns::cache', 'Sets up public dnscache service'
recipe            'djbdns::internal_server', 'Sets up internal TinyDNS'
recipe            'djbdns::server', 'Sets up external TinyDNS'

%w( build-essential daemontools bluepill ucspi-tcp ).each do |cb|
  depends cb
end

depends 'runit', '~> 1.6.0'

%w( ubuntu debian redhat centos scientific amazon oracle arch ).each do |os|
  supports os
end

source_url 'https://github.com/chef-cookbooks/djbdns' if respond_to?(:source_url)
issues_url 'https://github.com/chef-cookbooks/djbdns/issues' if respond_to?(:issues_url)
