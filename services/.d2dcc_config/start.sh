#!/bin/bash
set -e

#  Create SSH authorisation key for the colibri ################################

mkdir -p ${HOME}/.ssh
export SSH_KEY=${HOME}/.ssh/id_${NAME}
eval "$(ssh-agent -s)"
ssh-keygen -t rsa -N "" -f $SSH_KEY
ssh-add $SSH_KEY

#  Configure Hostname and set up SSH Authorisation #############################

expect ${CONFIG_DIR}/init_server.exp

# Transfer Relevant files and start the server #################################

installer_dir=/tmp

export SSH_OPTION="-o PubkeyAcceptedKeyTypes=ssh-rsa"
scp -O ${SSH_OPTION} ${D2DCC_DIR}/bin/linux-arm_elhf/installer_server.sh \
    root@$NAME:$installer_dir

ssh ${SSH_OPTION} root@$NAME "
echo \"export K8S_FPGA_TYPE=$FPGA_TYPE
export K8S_FPGA_TYPE_NUMBER=$FPGA_TYPE_NUMBER
export LOG_FILE=$SERVER_LOG_FILE\" > /opt/server/server_env"

ssh ${SSH_OPTION} root@$NAME "cd $installer_dir; ./installer_server.sh -i"

# Start Soft IOC ###############################################################

case "$FPGA_TYPE" in
    SIC_DPS)
        echo >&1 "Running DPS Start Script"
        IOC_DIR=${D2DCC_DIR}/dpsApp
        ;;
    SOFB | FOFB)
        echo >&1 "Running FRC Start Script"
        IOC_DIR=${D2DCC_DIR}/frcApp
        ;;
    *)
        echo "Invalid FPGA Name: $FPGA_TYPE"
        exit 1
        ;;
esac

(trap 'kill 0' SIGINT; source ${CONFIG_DIR}/log_reader.sh & ${IOC_DIR}/runioc)
