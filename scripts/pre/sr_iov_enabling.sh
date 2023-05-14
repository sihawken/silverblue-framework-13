#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

# FOLLOWING INSTRUCTIONS FROM:
# https://www.michaelstinkerings.org/gpu-virtualization-with-intel-12th-gen-igpu-uhd-730/
# https://utcc.utoronto.ca/~cks/space/blog/linux/HandBuildKernelModule

# Install prerequisites

rpm-ostree install git make binutils kernel-devel-$(rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')
ln -s /usr/bin/ld.bfd /etc/alternatives/ld && ln -s /etc/alternatives/ld /usr/bin/ld

cd /usr/src/ && \
git clone https://github.com/strongtz/i915-sriov-dkms i915-sriov-dkms-6.1 && \
cd i915-sriov-dkms-6.1

rm -rf /lib/modules/$(rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')/kernel/drivers/gpu/drm/i915/i915.ko.xz

make -C /lib/modules/$(rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')/build M=$(pwd)
make -C /lib/modules/$(rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')/build M=$(pwd) modules_install
depmod -v /lib/modules/$(rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}') -a

# cd /usr/src/i915-sriov-dkms-6.1/
# xz i915.ko

# mv i915.ko.xz /lib/modules/$(rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')/kernel/drivers/gpu/drm/i915/i915.ko.xz

rm -rf /usr/src/i915-sriov-dkms-6.1

echo "devices/pci0000:00/0000:00:02.0/sriov_numvfs = 7" > /etc/sysfs.conf
