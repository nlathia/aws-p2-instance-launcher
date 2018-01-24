#!/bin/bash
# Configure & launch a p2.xlarge instance

# Uncomment for debugging
# set -x

# Abort if any command fails
set -e

log () {
    echo "$1" >&2
}

main() {
    hash aws 2>/dev/null
    if [ $? -ne 0 ]; then
        log "'aws' command line tool required, but not installed. Aborting."
        exit 1
    fi

    export AWS_DEFAULT_OUTPUT="text"
    if [ $# -eq 0 ]; then
        log "Launching with the default profile"
        export AWS_PROFILE=default
    else
        log "Launching with the $1 profile"
        export AWS_PROFILE=$1
    fi

    source ./setup_local.sh
    validateProfile
    instanceType="p2.xlarge" # TODO: set instance type with an argument
    instance_name=$(getInstanceName "$instanceType")
    ami=$(getAMIForCurrentRegion)

    source ./setup_aws.sh
    vpcId=$(createVPC "$instance_name")
    subnetId=$(createSubnet "$instance_name" "$vpcId")
    internetGatewayId=$(createGateway "$instance_name")
    attachGateway "$instance_name" "$internetGatewayId" "$vpcId"

    routeTableId=$(createRouteTable "$instance_name" \
        "$vpcId" \
        "$internetGatewayId")
    routeTableAssoc=$(createRouteTableAssociation "$instance_name" \
        "$routeTableId" \
        "$subnetId")

    securityGroupId=$(createSecurityGroup "$instance_name" "$vpcId")
    keyFile=$(createKeyFile "$instance_name")
    instanceId=$(createInstance "$instance_name" \
        "$ami" \
        "$instanceType" \
        "$keyFile" \
        "$securityGroupId" \
        "$subnetId")
    assocId=$(getAssociationId "$instanceId")
    instanceIP=$(getInstanceIP "$instanceId")

    source ./setup_shortcuts.sh
    echo Creating shortcuts...
    writeConnectionShortcuts "$instance_name" "$key_file" "$instanceIP"
    writeStateShortcuts "$instance_name" "$instanceId"
    writeUninstall "$instance_name" "$AWS_PROFILE" "$instanceId" "$securityGroupId" "$assocId" "$allocAddr" "$routeTableAssoc" "$routeTableId" "$internetGatewayId" "$vpcId" "$subnetId"
    chmod u+x "$instance_name-*.sh"

    log Finished.
}

main "$@"
