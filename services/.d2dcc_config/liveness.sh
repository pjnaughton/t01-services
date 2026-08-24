#!/bin/bash
TOP=/epics/ioc
cd ${TOP}
CONFIG_DIR=${TOP}/config

set -ex

case "$FPGA_TYPE" in
    SIC_DPS)
        LIVENESS_PV=( "${NAME}:STATE" )
        ;;
    SOFB | FOFB)
        for MAGNET_NAME in "MAGNET_ONE" "MAGNET_TWO" "MAGNET_THREE" "MAGNET_FOUR"; do
            if [[ ! -z "${!MAGNET_NAME}" ]]; then
                LIVENESS_PV+=( "${!MAGNET_NAME}:STATE" )
            fi
        done
        ;;
    *)
        echo "Invalid FPGA Name $FPGA_TYPE"
        exit 1
        ;;
esac

for pv in ${LIVENESS_PV[@]}; do
    if ! caget ${pv} ; then
        echo "Liveness check failed for ${IOC_NAME}" > /proc/1/fd/1
        echo "Failing PV: ${pv}" > /proc/1/fd/2
        exit 1
    fi
done
