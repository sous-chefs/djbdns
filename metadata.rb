name              'djbdns'
maintainer        'Joshua Timberman'
maintainer_email  'cookbooks@housepub.org'
license           'Apache 2.0'
description       'Installs djbdns and configures DNS services'
version           '1.1.0'
recipe            'djbdns', 'Installs djbdns from package or source and creates users'
recipe            'djbdns::axfr', 'Sets up djbdns AXFR service'
recipe            'djbdns::cache', 'Sets up public dnscache service'
recipe            'djbdns::internal_server', 'Sets up internal TinyDNS'
recipe            'djbdns::server', 'Sets up external TinyDNS'

%w{ build-essential daemontools bluepill ucspi-tcp }.each do |cb|
  depends cb
end

depends 'runit', '~> 1.6'

%w{ ubuntu debian redhat centos scientific amazon oracle arch }.each do |os|
  supports os
end
