# Intel CLCK nodefile example
echo '#Example
cn-1      # role: compute
cn-2      # role: compute' > ~/nodefile

# Agent forwarding
ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa
echo 'Host *
    IdentityFile ~/.ssh/id_rsa
    ForwardAgent yes' > ~/.ssh/config
chmod 600  ~/.ssh/.ssh/config
cat ~/.ssh/id_rsa >> .ssh/authorized_keys 

echo '# Intel PSXE Paths
PATH=/opt/intel/intelpython2/bin/:$PATH
PATH=/opt/intel/intelpython3/bin/:$PATH
source /opt/intel/psxe_runtime/linux/bin/psxevars.sh' >> ~/.bashrc
