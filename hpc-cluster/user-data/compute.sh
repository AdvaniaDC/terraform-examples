#!/bin/bash

# Advania DC
# HPCFLOW
# Compute node
#

# Install dependencies
yum -y install nfs-utils yum-utils gcc libstdc++-devel infiniband-diags

# Install Intel HPC Platform
rpm --import http://yum.repos.intel.com/hpc-platform/el7/setup/PUBLIC_KEY.PUB
yum-config-manager --add-repo http://yum.repos.intel.com/hpc-platform/el7/setup/intel-hpc-platform.repo
yum -y install intel-hpc-platform-*


# Mounts
mkdir /opt/intel

echo '
login:/home  /home  nfs4  rw,hard,timeo=14  0 0
login:/opt/intel  /opt/intel  nfs4  rw,hard,timeo=14  0 0
' >> /etc/fstab

mount /home
mount /opt/intel
