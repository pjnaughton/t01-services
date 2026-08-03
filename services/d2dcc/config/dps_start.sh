#!/bin/sh

# Script for starting IOC
DEVICE="$(hostname -s)"

PERSISTANCE=/opt/state/$DEVICE.state
[ -r $PERSISTANCE ]  &&
    PERSISTANCE_OPT="-p$PERSISTANCE"

ERROR_FILE=/opt/ioc/install_d/errors.txt
[ -r $ERROR_FILE ]  &&
    ERROR_FILE_OPT="-e$ERROR_FILE"


DEFAULT_PORT=8888
SERVER_PORT=${PORT:=$DEFAULT_PORT}

DEFAULT_HOST=localhost
SERVER_HOSTNAME=${HOSTNAME:=$DEFAULT_HOST}

export EPICS_CA_MAX_ARRAY_BYTES=1000000

#cd "$D2DCC_DIR/dpsApp"
cd /epics/support/d2dcc/dpsApp
OPTS="$PERSISTANCE_OPT $ERROR_FILE_OPT"
ARCH="$(uname -m)"
if [ $ARCH = "x86_64" ]; then
    BIN_DIR="bin/linux-$ARCH"
else
    BIN_DIR="bin/linux-arm_elhf"
fi

ARGS="$DEVICE $SERVER_HOSTNAME $SERVER_PORT"
echo ${pwd}
$BIN_DIR/dls_dps $OPTS $ARGS
