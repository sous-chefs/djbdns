# Limitations

## Product Status

djbdns 1.05 is distributed from Daniel J. Bernstein's public djbdns site at <https://cr.yp.to/djbdns.html>. The upstream source distribution is old and does not publish a modern vendor package repository.

## Package Availability

### APT (Debian/Ubuntu)

This cookbook supports source installation on current Debian and Ubuntu releases. Package installation remains available through the `install_method 'package'` and `package_name` properties for users whose distribution provides `djbdns` or the Debian `dbndns` fork.

### DNF/YUM (RHEL family, Fedora, Amazon Linux)

No official vendor DNF/YUM repository exists. The supported path is source installation with platform build tools.

### Zypper (SUSE)

No current SUSE support is declared by this cookbook.

## Architecture Limitations

Source installation is architecture-independent in cookbook logic, but depends on the target platform's compiler toolchain and C library compatibility.

## Source/Compiled Installation

### Build Dependencies

| Platform Family | Packages/Resources |
|-----------------|--------------------|
| Debian          | `build_essential`  |
| RHEL/Fedora     | `build_essential`  |
| Amazon          | `build_essential`  |

## Known Issues

* djbdns services are managed under runit because the upstream configuration tools generate runit-compatible service directories.
* Source installation downloads `djbdns-1.05.tar.gz` from the upstream site during convergence.
* Legacy node attributes and root recipes were removed in the full custom resource migration; use resource properties instead.
