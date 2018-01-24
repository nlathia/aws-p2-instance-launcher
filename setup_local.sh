#!/bin/bash
#
# These functions are called in ../launch.sh

log () {
    echo "$1" >&2
}

# --------------------------------------------------------- #
# getInstanceName ()
# Parameters: $instanceType
# --------------------------------------------------------- #
function getInstanceName {
    if [ "$1" = "p2.xlarge" ]; then
        instance_name="gpu-machine"
    else
        instance_name="test-machine"
    fi
    log "Instance name: $instance_name"
    echo "$instance_name"
}

# --------------------------------------------------------- #
# validateProfile ()
# Make sure that the profile exists
# Make sure that the profile has been configured
# --------------------------------------------------------- #
function validateProfile {
    if [[ $(aws configure list) && $? -ne 0 ]]; then
        log "Unknown profile! Aborting."
        exit 1
    fi
    if [ -z "$(aws configure get aws_access_key_id)" ]; then
        log "AWS credentials not configured. Aborting."
        exit 1
    fi
}

# --------------------------------------------------------- #
# getAMI ()
# Set the correct ami, based on the profile's region
# --------------------------------------------------------- #
function getAMIForCurrentRegion {
    region=$(aws configure get region)
    log "Your setup region is: $region"
    # TODO: add AMIs for other regions
    if [ $region = "eu-west-1" ]; then
        # https://aws.amazon.com/marketplace/pp/B077GF11NF
        ami="ami-70fe4609"
    else
        echo "Only eu-west-1 (Ireland) is currently supported."
        exit 1
    fi
    log "Using AMI: $ami"
    echo "$ami"
}
