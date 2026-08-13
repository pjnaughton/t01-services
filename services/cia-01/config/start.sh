#!/bin/bash
set -e

#  Start the server ############################################################

expect ${CONFIG_DIR}/init_server.exp
if [ $? != 0 ]; then
    exit 1
fi

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

source ${IOC_DIR}/runioc $EXTRA_OPTS
exit $?
