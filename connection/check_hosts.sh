#! /bin/bash

# Handling the arguments.
while getopts ":h" arg; do
    case "$arg" in
        h)
            echo "
./check_hosts.sh

List of options:
-h => prints the associated help.

Checks if all servers are alive a well.
Checks with a ssh connexion.
"
            exit 0
            ;;
        :)
            echo "The option \"${arg}\" needs an argument."
            echo "Try ./check_hosts.sh -h."
            exit 1
            ;;
        \?)
            echo "Unknown option: \"${OPTARG}\"."
            echo "Try ./check_hosts.sh -h."
            exit 1
            ;;
    esac
done

# Defining some "aliases" in order to make the code clearer.
FIRST_ID=161
LAST_ID=174
BASE_ADDR=10.11.51.
SSH_OPTIONS="-o StrictHostKeyChecking=no"
SSH_KEY=infra

echo "Report made on : $(date)"

# Iterating over all the servers to check if there are alive and well
# successful ssh connexion should be enough
for id in $(seq ${FIRST_ID} 1 ${LAST_ID}); do
    ip="${BASE_ADDR}${id}"
    
    if ERR=$(ssh "${SSH_OPTIONS}" -i "${SSH_KEY}" root@"$ip" exit 2>&1) 
    then
        echo "$ip" ": OK"
    else
        echo "$ip" ": KO !  $ERR"
    fi
done
