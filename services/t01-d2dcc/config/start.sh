#!/bin/bash
set -e

cd $D2DCC_DIR
#####  Start the server #####

TOOLS_PATH=${D2DCC_DIR}/tcpServer/tools

sed -i "s/@@FPGA_TYPE@@/$FPGA_TYPE/" $TOOLS_PATH/env
sed -i "s/@@FPGA_TYPE_NUM@@/$FPGA_TYPE_NUM/" $TOOLS_PATH/env

expect $TOOLS_PATH/init_server.exp

##### Start Soft IOC #####
if [[ "$FPGA_TYPE" == *"DPS"* ]]; then
    echo "Running DPS Start Script"
    IOC_DIR=dpsApp
elif [ "$FPGA_NAME" = "SOFB" ] || [ "$FPGA_NAME" = "FOFB" ]; then
    echo "Running FRC Start Script"
    IOC_DIR=frcApp
else
    echo "Invalid FPGA Name $FPGA_NAME"
    exit 1
fi

source ${IOC_DIR}/runioc $EXTRA_OPTS
