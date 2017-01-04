# /bin/bash

# This script fails if any command does.
set -eo pipefail

# Defining global parameters.
PROVISIONING_DIR=$(cd $(dirname $0) && pwd)
CONNECTION_DIR="${PROVISIONING_DIR}/../connection"
SSH_KEY="${CONNECTION_DIR}/g1"

# Lists all the available provisioning scripts, and prints a brief
# description of the latter.
# No argument.
# No returned value.
function list_provision
{
    cd "$PROVISIONING_DIR"
    for directory in *; do
        if [[ -d "$directory" ]]; then
            echo -e "\n${directory}"
            cat "${directory}/one_liner"
        fi
    done
}

# Checks whether a provisioning script exist or not.
# Argument:
#   1 => The name of the provisioning script (without ".sh").
#        The list of the available scripts can be printed
#        thanks to the "-l" option.
#
# Returned value:
#   0 => The script does not exist;
#   1 => The script does exist.
function check_provision
{
    cd "$PROVISIONING_DIR"
    local is_checked=0
    if [[ -d "$1" ]]; then
        is_checked=1
    fi

    echo "$is_checked"
}

# Handling the arguments.
TARGET=0
PROVISION=""
while getopts ":hln:p:" arg; do
    case "$arg" in
        h)
            echo "
./provision.sh

List of options:
-h        => prints the associated help;
-l        => lists all the provisioning option;
-n id     => specifies the ID of the targetted server;
-p script => specifies a provision script to execute on the 
          targetted server.

Provisions the designated host with specified provisioning script.

A small note on the ID range: it is within 1 <= ID <= 14 (\"1\" 
corresponding to \"c31\" and \"14\" to \"c44\").
"
            exit 0
            ;;
        l)
            echo -e "\nListing all provisioning scripts:"
            list_provision
            echo  ""
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
        p)
            COMMAND="$OPTARG"
            PROVISION="$OPTARG"
            checked=$(check_provision "$PROVISION")
            if [[ "$checked" -eq 0 ]]; then 
                echo "Unknown provisioning script: ${PROVISION}."
                echo "Try \"./provision.sh -h\" or \"./provision.sh -l\"."
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

# Checking that the target and the script have been specified.
if [[ -z "$PROVISION" || -z "$TARGET" ]]; then
    echo "Both the ID of the targetted server and the provisioning \
script should be specified.
Try \"./provision.sh -h\"."
    exit 1
fi

# From the name of the directory to the path of the script.
SCRIPT="${PROVISION}.sh"
PROVISION_PATH="${PROVISIONING_DIR}/${PROVISION}/${SCRIPT}"

# Copying the provisioning script to the host.
echo -e "\n[Provisioning - ${PROVISION}] Copying provisioning \
script to remote host ...\n"
cd "$CONNECTION_DIR"
./connect.sh -n "$TARGET" -s "$PROVISION_PATH"

# Executing the provisioning script on the targetted server, then
# removing it.
echo -e "\n[Provisioning - ${PROVISION}] Executing provisioning \
script on remote host ...\n"
./connect.sh -n "$TARGET" -c "./${SCRIPT} && rm -f ${SCRIPT}"

# Notifying the user that the provisioning has been completed.
echo -e "\n[Provisioning - ${PROVISION}] Provisioning complete."
