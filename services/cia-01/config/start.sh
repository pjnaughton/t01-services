#!/bin/bash
set -e

#  Start the server ############################################################

# expect ${CONFIG_DIR}/init_server.exp
# if [ $? != 0 ]; then
#     exit 1

# Start Soft IOC ###############################################################

case "$FPGA_TYPE" in
    SIC_DPS)
        echo >&1 "Running DPS Start Script"
        IOC_DIR=${D2DCC_DIR}/dpsApp
        ;;
    SOFB | FOFB)
        echo "Running FRC Start Script"
        IOC_DIR=${D2DCC_DIR}/frcApp
        ;;
    *)
        echo "Invalid FPGA Name $FPGA_TYPE"
        exit 1
        ;;
esac

echo "Hello World"
echo "IOC_DIR is $IOC_DIR"
echo "source ${IOC_DIR}/runioc $EXTRA_OPTS"
source ${IOC_DIR}/runioc $EXTRA_OPTS
