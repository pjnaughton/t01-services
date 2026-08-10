#!/bin/bash
set -e

#  Start the server ############################################################

expect ${CONFIG_DIR}/init_server.exp

# Start Soft IOC ###############################################################

if [[ "$FPGA_TYPE" == *"DPS"* ]]; then
    echo "Running DPS Start Script"
    IOC_DIR=${D2DCC_DIR}/dpsApp
elif [ "$FPGA_NAME" = "SOFB" ] || [ "$FPGA_NAME" = "FOFB" ]; then
    echo "Running FRC Start Script"
    IOC_DIR=${D2DCC_DIR}/frcApp
else
    echo "Invalid FPGA Name $FPGA_NAME"
    exit 1
fi

source ${IOC_DIR}/runioc $EXTRA_OPTS
