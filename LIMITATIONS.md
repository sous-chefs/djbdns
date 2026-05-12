# Limitations

## Package Availability

### Upstream / Vendor

* Upstream publishes source tarballs and installation instructions, not an official package repository. The latest published upstream tarball is `djbdns-1.05.tar.gz`.
* Upstream installation guidance requires a UNIX-like system plus `daemontools` 0.70 or later and `ucspi-tcp`, then a local compile and `make setup check`.

### APT (Debian / Ubuntu)

* Debian still ships `djbdns` as a maintained source package and builds split binaries including `axfrdns`, `djbdns-conf`, `djbdns-utils`, `dnscache`, `rbldns`, `tinydns`, and `walldns`.
* Debian package pages for current and recent releases show distro-managed package availability for supported Debian architectures.
* Ubuntu still carries `djbdns` in the `universe` source package set. The cookbook's current package-install path is therefore most defensible on Debian-family platforms.

### DNF / YUM (RHEL family)

* I did not find a primary-source upstream package repository for RHEL-family systems.
* Inference: the cookbook's source-install path remains the only installation path directly backed by upstream documentation for RHEL-family platforms.
* Current integration evidence supports AlmaLinux 9 and CentOS Stream 9 only. Amazon Linux 2023, CentOS Stream 10, and Rocky Linux 10 are not advertised in CI or metadata because they are not currently viable in this cookbook's Dokken matrix.

### Zypper (SUSE)

* I did not find a primary-source upstream package repository for SUSE/openSUSE.
* Inference: source installation is also the only path clearly supported by upstream guidance on SUSE-family platforms.

## Architecture Limitations

* Upstream does not publish a tested architecture matrix; its guidance is source-build oriented rather than architecture-specific.
* Debian and Ubuntu package availability is distribution-managed and architecture-dependent. The cookbook should treat package installs as Debian-family specific, not universally portable.

## Source / Compiled Installation

### Build Dependencies

* Debian: compiler and build tools; upstream also requires `daemontools` and `ucspi-tcp`
* RHEL: compiler and build tools; upstream also requires `daemontools` and `ucspi-tcp`
* SUSE: compiler and build tools; upstream also requires `daemontools` and `ucspi-tcp`

## Known Issues

* The cookbook's `install_method` heuristic is cookbook-local logic, not upstream vendor guidance.
* `axfrdns` depends on `tcpserver` from `ucspi-tcp`, but the cookbook does not yet model that dependency as a first-class resource concern.
* Prior Dokken failures were gated by the shared `runit` dependency rather than djbdns resource convergence. This migration replaces that supervision layer with native systemd units so the remaining integration coverage reflects djbdns behavior instead of `runit` packaging.
* Debian 13 and RHEL-family 10 builds currently expose upstream `djbdns-1.05` compile incompatibilities with newer system toolchains. They should be revisited as a separate platform enablement effort rather than advertised as supported.
