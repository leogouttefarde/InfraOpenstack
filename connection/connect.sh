#! /bin/bash

# This script fails if any command does.
set -eo pipefail

# Handling the arguments.
TARGET=0
COMMAND=""
FILE=""
while getopts ":hn:c:s:" arg; do
    case "$arg" in
        h)
            echo "
./connect.sh

List of options:
-h      => prints the associated help;
-n id   => specifies the ID of the targeted server;
-c cmd  => specifies a command to execute on the server;
-s file => turns the connection into a SCP sending of \"file\".
(-s and -c are mutually exclusive)

Connects to one of the Helion servers. The ID of the targeted server
corresponds to its place in the list of servers contained in the
OpenVPN connection tutorial supplied by HP for the first lab.

As a consequence, it is within the range 1 <= ID <= 14 (\"1\" 
corresponding to \"c31\" and \"14\" to \"c44\").
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
        c)
            COMMAND="$OPTARG"
            ;;
        s)
            if [[ -f "$OPTARG" ]]; then
                FILE="$OPTARG"
            else
                echo "${OPTARG} is not a file."
                echo "Try \"./connect.sh -h.\""
                exit 1
            fi
            ;;
        :)
            echo "The option \"${arg}\" needs an argument."
            echo "Try ./connect.sh -h."
            exit 1
            ;;
        \?)
            echo "Unknown option: \"${OPTARG}\"."
            echo "Try ./connect.sh -h."
            exit 1
            ;;
    esac
done

# Verifying that the two mutually exclusive options "-c"
# and "-s" have not been both specified.
if [[ ! -z "$COMMAND" && ! -z "$FILE" ]]; then
    echo "The options \"-c\" and \"-s\" are mutually exclusive."
    echo "Try \"./connect.sh -h.\""
    exit 1
fi

# Defining some useful "macros" to make the code clearer.
BASE_ADDR=10.11.51.
BASE_ID=160
SSH_KEY=infra

# Computing the IP address of the targeted server.
let "ip_id = BASE_ID + TARGET"
ip_addr="${BASE_ADDR}${ip_id}"

# Connecting to the targeted server, either in interactive mode 
# or to execute a command.
# Also taking into account the possibility to send a file via SCP.
if [[ -z "$COMMAND" ]]; then
    if [[ -z "$FILE" ]]; then
        ssh -i ${SSH_KEY} root@"$ip_addr"
    else
        scp -i "$SSH_KEY" "$FILE" root@"$ip_addr":/root
    fi
else
    ssh -i ${SSH_KEY} root@"$ip_addr" "$COMMAND"
fi
