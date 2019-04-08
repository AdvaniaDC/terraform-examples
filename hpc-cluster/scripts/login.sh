#!/bin/bash

# Add Intel yum repos
rpm --import https://yum.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB
yum-config-manager --add-repo https://yum.repos.intel.com/clck/2019/setup/intel-clck-2019.repo
yum-config-manager --add-repo https://yum.repos.intel.com/clck-ext/2019/setup/intel-clck-ext-2019.repo
yum-config-manager --add-repo http://yum.repos.intel.com/hpc-platform/el7/setup/intel-hpc-platform.repo
rpm --import https://yum.repos.intel.com/hpc-platform/el7/setup/PUBLIC_KEY.PUB
rpm --import https://yum.repos.intel.com/2019/setup/RPM-GPG-KEY-intel-psxe-runtime-2019
yum -y install https://yum.repos.intel.com/2019/setup/intel-psxe-runtime-2019-reposetup-1-0.noarch.rpm
yum-config-manager --add-repo https://yum.repos.intel.com/intelpython/setup/intelpython.repo
#for filename in /etc/yum.repos.d/intel*; do echo "proxy=http://82.221.76.47:3128" >> $filename; done

# Install Intel CLCK
yum -y install intel-clck-2019.0-015
yum -y install intel-clck-hpc-platform
cp /opt/intel/clck/2019.0/etc/clck.xml{,.backup}

# Install Intel HPC Platform
yum -y install intel-hpc-platform-*

# Common mounts (shared home directory and /opt/intel)
yum -y install nfs-utils
systemctl enable rpcbind
systemctl enable nfs-server
systemctl enable nfs-lock
systemctl enable nfs-idmap
systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap

echo '/home *(rw,no_subtree_check,fsid=10,no_root_squash)
/opt/intel *(rw,no_subtree_check,fsid=11)' > /etc/exports

sudo exportfs -ra

# Install Intel PSXE runtime
yum -y install intel-psxe-runtime
yum -y install gcc libstdc++-devel
yum -y install intelpython2 intelpython3
