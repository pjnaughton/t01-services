if [ "$FPGA_NAME" = "DPS" ]; then
    echo "Running DPS Start Script"
    source ${IOC}/config/dps_start.sh
elif [ "$FPGA_NAME" = "FRC" ]; then
    echo "Running FRC Start Script"
    source ${IOC}/config/frc_start.sh
else
    echo "Invalid FPGA Name $FPGA_NAME"
    exit 1
fi
