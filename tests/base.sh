set -ex

function teardown()
{
    local exit_code=${1:-$?}
    # vagrant destroy -f
    echo $0 status: $exit_code
}

error_exit() {
    echo "Error on line $1"
    exit 1
}

function wait_service()
{
    local timeout=60
    local url=$1
    local reply_keyword=$2
    while [[ $timeout -gt 0 ]]; do
        local response=$(curl -s -XGET "$url" | grep "$reply_keyword")
        if [ ! -z "$response" ]
        then
            echo FOUND $url
            return 0
        fi
        sleep 3
        (( timeout-- ))
        echo wait_service $url $timeout sec..
    done
    echo ERROR: $url is not responding
    return 1
}

trap teardown EXIT
trap 'error_exit $LINENO' ERR

# defined in Vagrantfile
vmbox1=192.168.10.101
vmbox2=192.168.10.102

ssh-keygen -f $HOME/.ssh/known_hosts -R $vmbox1
ssh-keygen -f $HOME/.ssh/known_hosts -R $vmbox2
