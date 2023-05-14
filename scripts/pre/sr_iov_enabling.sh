#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!

set -oue pipefail

# FOLLOWING INSTRUCTIONS FROM:
# https://www.michaelstinkerings.org/gpu-virtualization-with-intel-12th-gen-igpu-uhd-730/
# https://utcc.utoronto.ca/~cks/space/blog/linux/HandBuildKernelModule

# Disabled all of these commands because I cannot get it to work with

rpm-ostree install dkms akmods git make binutils kernel-headers kernel-devel-$(rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')
cd /usr/src/
git clone https://github.com/strongtz/i915-sriov-dkms i915-sriov-dkms-6.1
cd i915-sriov-dkms-6.1

sed -i 's/PACKAGE_NAME="@_PKGBASE@"/PACKAGE_NAME="i915-sriov-dkms"/g' dkms.conf
sed -i 's/PACKAGE_VERSION="@PKGVER@"/PACKAGE_VERSION="6.1"/g' dkms.conf
#sed -i 's/kernel_source_dir/KERNEL_SOURCE_DIR_BUILD/g' dkms.conf

#echo KERNEL_SOURCE_DIR_BUILD='"/lib/modules/$(rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')/build"' | cat - dkms.conf > temp && mv temp dkms.conf

ln -s /usr/bin/ld.bfd /etc/alternatives/ld && ln -s /etc/alternatives/ld /usr/bin/ld

dkms add --rpm_safe_upgrade -k $(rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}') -m i915-sriov-dkms -v 6.1
dkms build -k $(rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}') -m i915-sriov-dkms -v 6.1
dkms install -k $(rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}') -m i915-sriov-dkms -v 6.1 --force
akmods --force --kernels "$(rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"

## DIFFERENT ATTEMPT

# # Install prerequisites

# rpm-ostree install git make binutils kernel-devel-$(rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')
# ln -s /usr/bin/ld.bfd /etc/alternatives/ld && ln -s /etc/alternatives/ld /usr/bin/ld

# cd /usr/src/ && \
# git clone https://github.com/strongtz/i915-sriov-dkms i915-sriov-dkms-6.1 && \
# cd i915-sriov-dkms-6.1

# # rm -rf /lib/modules/$(rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')/kernel/drivers/gpu/drm/i915/i915.ko.xz

# make -C /lib/modules/$(rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')/build M=$(pwd)
# cd /usr/src/i915-sriov-dkms-6.1/
# xz i915.ko
# mv i915.ko.xz /lib/modules/$(rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')/updates/i915.ko.xz
# # make -C /lib/modules/$(rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')/build M=$(pwd) modules_install

# echo "override i915 * updates > /etc/depmod.d/i915.conf"

# depmod -v $(rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')

# # mv i915.ko.xz /lib/modules/$(rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')/kernel/drivers/gpu/drm/i915/i915.ko.xz

# # rm -rf /usr/src/i915-sriov-dkms-6.1

# # sysfsutils stuff
# rpm-ostree install sysfsutils
# echo "devices/pci0000:00/0000:00:02.0/sriov_numvfs = 7" > /etc/sysfs.conf
