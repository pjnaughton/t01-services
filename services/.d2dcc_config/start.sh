#!/bin/bash

set -xe

case "$FPGA_TYPE" in
    SIC_DPS)
        #fpga_bins=( ${FPGA_BIN_DIR}/SIC/firmware/sic.bin
        #            ${FPGA_BIN_DIR}/DPS/firmware/dps.bin )
        ioc_dir=${D2DCC_DIR}/dpsApp
        ;;
    SOFB | FOFB)
        # fpga_bins=( ${FPGA_BIN_DIR}/FRC/firmware/frc.bin  )
        ioc_dir=${D2DCC_DIR}/frcApp
        ;;
    *)
        echo "Invalid FPGA Name: $FPGA_TYPE"
        exit 1
        ;;
esac

# Create directory on PVC for the IOC
mkdir -p /data/${NAME}

#  Create SSH authorisation key for the colibri ################################

mkdir ${HOME}/.ssh
export SSH_KEY="${HOME}/.ssh/id_$NAME"
eval "$(ssh-agent -s)"
ssh-keygen -t rsa -N "" -f $SSH_KEY
ssh-add $SSH_KEY

#  Configure Hostname and set up SSH Authorisation #############################

expect ${CONFIG_DIR}/init_server.exp

# Transfer Relevant files and start the server #################################

installer_dir=/tmp

export SSH_OPTION="-o PubkeyAcceptedKeyTypes=ssh-rsa"
scp -O $SSH_OPTION ${D2DCC_DIR}/bin/linux-arm_elhf/installer_server.sh \
    root@$NAME:$installer_dir

send_ssh_command() {
    local command=$1
    ssh $SSH_OPTION root@$NAME "$command"
}

# ssh_command "mkdir -p /opt/fpga/"
# scp -O $SSH_OPTION ${fpga_bins[*]@Q} root@$NAME:/opt/fpga/

# We must create the environment file after the installer script as it will
# otherwise get deleted.
send_ssh_command "cd $installer_dir; ./installer_server.sh -n"

send_ssh_command "echo \"export K8S_FPGA_TYPE=$FPGA_TYPE
export K8S_FPGA_TYPE_NUMBER=$FPGA_TYPE_NUMBER
export LOG_FILE=$SERVER_LOG_FILE\" > /opt/server/server_env"

send_ssh_command "/opt/etc/init.d/tcpserver start"

# Start Soft IOC ###############################################################

export PERSISTENCE_FILE="/data/${NAME}/${NAME}.state"
export ERROR_FILE="${ioc_dir}/install_d/errors.txt"

source ${CONFIG_DIR}/log_reader.sh & 
${ioc_dir}/runioc
