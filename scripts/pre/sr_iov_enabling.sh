#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

# FOLLOWING INSTRUCTIONS FROM:
# https://www.michaelstinkerings.org/gpu-virtualization-with-intel-12th-gen-igpu-uhd-730/

# Install prerequisites
rpm-ostree install dkms sysfsutils linux-headers-$(rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')
echo "devices/pci0000:00/0000:00:02.0/sriov_numvfs = 7" > /etc/sysfs.conf

#Part 3.1 - Installing the dkms module
cd /usr/src/
wget https://mirrors.apqa.cn/d/proxmox-edge/intel_gpu_sriov/i915-sriov-dkms-6.1.zip
unzip i915-sriov-dkms-6.1.zip
cd i915-sriov-dkms-6.1/
dkms add .
dkms install i915-sriov-dkms/6.1