set -e

function teardown()
{
    local exit_code=${1:-$?}
    # vagrant destroy -f
    echo $0 status: $exit_code
}
trap teardown EXIT

# defined in Vagrantfile
vmbox1=192.168.10.101
vmbox2=192.168.10.102

ssh-keygen -f $HOME/.ssh/known_hosts -R $vmbox1
ssh-keygen -f $HOME/.ssh/known_hosts -R $vmbox2
