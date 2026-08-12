#!/bin/bash

# load ec configured for the training beamline user
module load ec/user

# re-configure it to point at your personal namespace
EC_SERVICES_REPO=https://github.com/pjnaughton/t01-services
EC_TARGET=accelerator/t01

# load argus configuration for kubectl
module load pollux
