# djbdns Cookbook CHANGELOG

This file is used to list changes made in each version of the djbdns cookbook.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

## 5.1.16 - *2024-05-01*

## 5.1.15 - *2024-05-01*

## 5.1.14 - *2024-02-17*

Fix markdown

## 5.1.13 - *2023-09-28*

## 5.1.12 - *2023-09-04*

## 5.1.11 - *2023-09-04*

## 5.1.10 - *2023-06-08*

Standardise files with files in sous-chefs/repo-management

## 5.1.9 - *2023-05-17*

## 5.1.8 - *2023-05-03*

## 5.1.7 - *2023-04-01*

## 5.1.6 - *2023-03-02*

## 5.1.5 - *2023-02-14*

## 5.1.4 - *2023-02-14*

- Remove delivery folder

## 5.1.3 - *2022-01-18*

- resolved cookstyle error: tasks/maintainers.rb:37:7 convention: `Style/FileWrite`

## 5.1.2 - *2021-08-31*

- Standardise files with files in sous-chefs/repo-management

## 5.1.1 (2021-06-01)

- Standardise files with files in sous-chefs/repo-management

## 5.1.0 (2020-11-13)

### Changed

- Sous Chefs Adoption
- Update Changelog to Sous Chefs
- Update to use Sous Chefs GH workflow
- Update test-kitchen to Sous Chefs
- Update README to sous-chefs
- Update metadata.rb to Sous Chefs

### Fixed

- Yamllint fixes
- MDL fixes
- Fix integration tests

### Added

- Add Ubuntu 20.04 testing

## 5.0.2 (2019-03-18)

- Add a basic converge unit test - [@tas50](https://github.com/tas50)
- Make sure we have wget for source installs - [@tas50](https://github.com/tas50)
- Update Test Kitchen platforms - [@tas50](https://github.com/tas50)
- Add code owners file - [@tas50](https://github.com/tas50)
- Rename the kitchen config - [@tas50](https://github.com/tas50)
- Remove Ubuntu 14.04 testing for 18.04 - [@tas50](https://github.com/tas50)
- Delete the dangling dependency on ucspi-tcp - [@RoboticCheese](https://github.com/RoboticCheese)
- Stop creating the runit service directory - [@RoboticCheese](https://github.com/RoboticCheese)
- Resolve FoodCritic offenses - [@RoboticCheese](https://github.com/RoboticCheese)

## 5.0.1 (2017-04-26)

- Test with Local Delivery and not Rake
- Move templates out of the default directory since only Chef < 12 requires this

## 5.0.0 (2017-02-14)

- Require 12.5 and remove compat_resource dependency

## 4.1.0 (2017-01-17)

- Require the latest compat_resource
- Switch to Inspec for integration testing
- Remove RHEL 5 testing as it's near EOL

## 4.0.0 (2016-12-05)

- Prevent compile error with source updating method
- Add ChefSpec matchers
- Convert LWRP to a custom resource and use compat_resource for 12.1+ compatibility
- Make sure IPSEND is set so the cache starts
- Fix Chef 13 compatibility by updating manage_home

## 3.0.0 (2016-09-15)

- Testing updates and remove FQDN from templates
- Update maintainers wording and format [skip-ci]
- Testing updates
- Require Chef 12.1+

## v2.0.0 (2016-05-20)

### BREAKING CHANGE

This version removes support for bluepill and daemontools init systems and Arch Linux. If you rely on that support you'll want to pin to the 1.2.0 release

This version now manages all djbdns env files to be compatible with the newest runit release. If you manage these files outside of the djbdns recipe you'll need to use the new attributes

## v1.2.0

- Removed newlines in configs to prevent restarts
- Removed inclusion of ucspi-tcp recipe for source installs
- Convert hashes to Ruby 1.9+ format
- Bump Runit dependency to 1.6.0 from 1.5.0
- Updated Test Kitchen config with the latest platforms and a suite for source install
- Added Travis CI config
- Added a simple contributing doc to replace the Chef Software Inc version
- Updated the development gem requirements and break gems into groups in the gemfile
- Added a cookbook version badge in the readme
- Added a chefignore file to limit what files are uploaded to the chef server
- Added additional platforms to the metadata
- Add source_url and issues_url to the metadata
- Make modes strings to preserve the leading 0s
- Resolve rubocop warnings
- Added additional unit tests

## v1.1.0

- Update dependency for current runit cookbook, #7
- Debian is a source based platform, #9 (see issue for background)
- Add `package_name` attribute to allow for installing [dbndns](http://en.wikipedia.org/wiki/Dbndns), #16, related to #9
- Use runit as default service type instead of bluepill, #10
- Drop explicit support for old unsupported Ubuntu versions, #11
- Manage runit's sv dir for "reasons," #12
- Remove attributes from metadata, as they're not used for anything anywhere anyway

## v1.0.2

- [COOK-2262] - pin runit dependency

## v1.0.0

- [COOK-1739] - use node attributes with hash notation instead of just the attribute name (ipaddress, domain) in djbdns attributes file
- [COOK-1742] - fix foodcritic warnings, use platform_family where apropriate

## v0.99.4

- [COOK-1259] - Support local (10.x, 172.x, 192.168.x) reverse lookups in cache

## v0.99.2

- [COOK-1042] - Corrected a syntax error in axfr.
- [COOK-740] - use correct directory for tinydns root data

## Previous versions

The various recipes now support multiple service types. This is controlled with the `node[:djbdns][:service_type]` attribute, which is set by platform in the default recipe.

ArchLinux support has been added, as well as naively attempting other platforms by source-compiled installation with bluepill for service management.
