#! /bin/bash

# This script fails if any command does.
set -eo pipefail

# Handling the arguments.
TARGET=""
MASTER=""
while getopts ":hm:n:p:" arg; do
    case "$arg" in
        h)
            echo "
./setup_connections.sh

List of options:
-h    => prints the associated help.
-n id => only set up connection to the server which ID is \"id\".
-m id => copy the infra key and add it to the server which ID is \"id\" 
-p passwd => specify the root password for the host 

Connects to all of the Helion server in order to setup a passwordless
SSH connection. In order:
    - The \".ssh\" directory is created, if necessary;
    - The \"authorized_keys\" file is created, if necessary;
    - The RSA public key is sent to the server, and saved into the \
\"authorized_keys\" file.
"

            exit 0
            ;;
        n)
            if [[ "$OPTARG" -le 0 || "$OPTARG" -ge 15 ]]; then
                echo "The ID must be within [[1 ; 14]]."
                echo "Try ./connect.sh -h."
                exit 1
            fi
            TARGET="$OPTARG"
            ;;
        m) 
            if [[ "$OPTARG" -le 0 || "$OPTARG" -ge 15 ]]; then
                echo $OPTARG
                echo "The ID must be within [[1 ; 14]]."
                echo "Try ./connect.sh -h."
                exit 1
            fi
            MASTER="$OPTARG"
            ;;
        p)
            root_pass="$OPTARG"
            ;; 
        :)
            echo "The option \"${arg}\" needs an argument."
            echo "Try ./setup_connections.sh -h."
            exit 1
            ;;
        \?)
            echo "Unknown option: \"${OPTARG}\"."
            echo "Try ./setup_connections.sh -h."
            exit 1
            ;;
    esac
done

# Defining some "aliases" in order to make the code clearer.
FIRST_ID=161
LAST_ID=174
BASE_ADDR=10.11.51.
SSH_OPTIONS="-oStrictHostKeyChecking=no"
SSH_KEY=infra.pub
SSH_PRIVATE_KEY=infra
CUSTOM_BASH_PROFILE=custom_bash_profile

# Adjusting the value of TARGET, if needed.
if [[ ! -z "$TARGET" ]]; then
    let "TARGET = TARGET + FIRST_ID - 1"
fi

# Asks, in a relatively secured way, for the SSH password if needed.

if [[ -z "$root_pass" ]]; then
    read -s -p "Remote host root password:" root_pass
    echo -e "\n"
fi

# Iterating over all the servers in order to setup passwordless SSH
# connections.
for id in $(seq ${FIRST_ID} 1 ${LAST_ID}); do
    # Skipping the unwanted servers if an ID has been provided.
    if [[ ! -z "$TARGET" ]]; then
        if [[ "$id" -ne "$TARGET" ]]; then
            continue
        fi
    fi
    # Defining the IP address of the server to setup connection to.
    ip="${BASE_ADDR}${id}"
    echo "Setting up the connection to the server ${ip}..."
    # If needed, creating the ".ssh" directory.
    sshpass -p "$root_pass" ssh "${SSH_OPTIONS}" root@"$ip" mkdir -p /root/.ssh
    # If needed, creating the "authorized_keys" file.
    sshpass -p "$root_pass" ssh "${SSH_OPTIONS}" root@"$ip" \
        touch /root/.ssh/authorized_keys 

    # Sending the public RSA key to the server.
    sshpass -p "$root_pass" scp "${SSH_OPTIONS}" "${SSH_KEY}" \
        root@"$ip":/root/.ssh/

    # Deleting the previously added public key.
    sshpass -p "$root_pass" ssh "${SSH_OPTIONS}" root@"$ip" \
        "sed -i \"/mats/d\" /root/.ssh/authorized_keys"

    # Marking the RSA public key as authorized, then deleting it.
    sshpass -p "$root_pass" ssh "${SSH_OPTIONS}" root@"$ip" \
        "cat /root/.ssh/${SSH_KEY} >> /root/.ssh/authorized_keys && \
         rm -f /root/.ssh/${SSH_KEY}"
done



if [[ ! -z "$MASTER" ]]; then
    let "MASTER = MASTER + FIRST_ID - 1"

    MASTER="${BASE_ADDR}${MASTER}"
    echo "Gives access to $MASTER to other machines"    
    # Copy the infra key on the machine
    sshpass -p "$root_pass" scp "${SSH_OPTIONS}" "${SSH_PRIVATE_KEY}" \
        root@"$MASTER":/root/.ssh/
    
    # Copy a custom bash profile with an ssh-agent
    sshpass -p "$root_pass" scp "${SSH_OPTIONS}" "${CUSTOM_BASH_PROFILE}" \
        root@"$MASTER":/root/.bash_profile
    
    # Add the key to the config file of ssh and source bash_profile to start 
    # ssh-agent
    sshpass -p "$root_pass" ssh "${SSH_OPTIONS}" root@"$ip" \
        "echo IdentityFile /root/.ssh/${SSH_PRIVATE_KEY} >> /root/.ssh/config && \
         source ~/.bash_profile"

fi


