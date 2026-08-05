if [ "$FPGA_NAME" = "DPS" ]; then
    echo "Running DPS Start Script"
    source ${D2DCC_DIR}/dpsApp/runioc $@
elif [ "$FPGA_NAME" = "FRC" ]; then
    echo "Running FRC Start Script"
    source ${D2DCC_DIR}/frcApp/runioc $@
else
    echo "Invalid FPGA Name $FPGA_NAME"
    exit 1
fi
