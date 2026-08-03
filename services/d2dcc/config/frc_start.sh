#!/bin/sh

# Script for starting IOC
HERE="$(dirname "$(readlink -f "$0")")"

DEVICE="$(hostname -s)"

PERSISTENCE=/opt/state/$DEVICE.state
[ -r $PERSISTENCE ]  &&
    PERSISTENCE_OPT="-p$PERSISTENCE"

ERROR_FILE=/opt/ioc/install_d/errors.txt
[ -r $ERROR_FILE ]  &&
    ERROR_FILE_OPT="-e$ERROR_FILE"


DEVICE_NAMES_DIR=/opt/ioc/install_d/device-names

# Load names from DEVICE name
if [ -e "$DEVICE_NAMES_DIR/$DEVICE" ]; then
    source "$DEVICE_NAMES_DIR/$DEVICE";
else
    echo >&2 Unable to load device names
    # Use fallback device names
    FRC_TYPE=FOFB
    MAGNET_ONE=MAGNET_ONE
    MAGNET_TWO=MAGNET_TWO
    MAGNET_THREE=MAGNET_THREE
    MAGNET_FOUR=MAGNET_FOUR
fi

DEFAULT_PORT=8888
SERVER_PORT=${PORT:=$DEFAULT_PORT}

DEFAULT_HOST=localhost
SERVER_HOSTNAME=${HOSTNAME:=$DEFAULT_HOST}

export EPICS_CA_MAX_ARRAY_BYTES=1000000

cd "$D2DCC_DIR/frcApp"
ARCH="$(uname -m)"
OPTS="$PERSISTANCE_OPT $ERROR_FILE_OPT"
if [ $ARCH = "x86_64" ]; then
    BIN_DIR="bin/linux-$ARCH"
else
    BIN_DIR="bin/linux-arm_elhf"
fi

ARGS="$DEVICE $SERVER_HOSTNAME $SERVER_PORT \
    $MAGNET_ONE $MAGNET_TWO $MAGNET_THREE $MAGNET_FOUR"

$BIN_DIR/dls_frc $OPTS $ARGS
