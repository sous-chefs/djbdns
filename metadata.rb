name              'djbdns'
maintainer        'Chef Software, Inc.'
maintainer_email  'cookbooks@chef.io'
license           'Apache-2.0'
description       'Installs djbdns and configures DNS services'
version           '5.0.2'
depends 'runit', '>= 1.6.0'

%w( ubuntu debian redhat centos scientific amazon oracle ).each do |os|
  supports os
end

source_url 'https://github.com/chef-cookbooks/djbdns'
issues_url 'https://github.com/chef-cookbooks/djbdns/issues'
chef_version '>= 14'
