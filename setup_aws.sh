#!/bin/bash
#
# These functions are called in ../launch.sh

log () {
    echo "$1" >&2
}

# --------------------------------------------------------- #
# createVPC ()                                              #
# An Internet gateway is a VPC component that allows        #
# communication between instances in your VPC and           #
# the Internet.                                             #
# Parameters: $instance_name
# --------------------------------------------------------- #
function createVPC {
    local vpcId=$(aws ec2 describe-vpcs \
        --filters "Name=tag-value,Values=$1" \
        --query "Vpcs[0].VpcId")
    if [ "$vpcId" = "None" ]; then
        log "Creating a VPC..."
        vpcId=$(aws ec2 create-vpc \
            --cidr-block 10.0.0.0/28 \
            --query 'Vpc.VpcId')
        aws ec2 create-tags \
            --resources "$vpcId" \
            --tags Key=Name,Value="$1"
        aws ec2 modify-vpc-attribute \
            --vpc-id "$vpcId" \
            --enable-dns-support "{\"Value\":true}"
        aws ec2 modify-vpc-attribute \
            --vpc-id "$vpcId" \
            --enable-dns-hostnames "{\"Value\":true}"
    fi
    log "Your VPC id is: $vpcId"
    echo "$vpcId"
}

# --------------------------------------------------------- #
# createSubnet ()                                           #
# VPC-only instances need to specify a subnet ID            #
# Parameters: $instance_name, $vpcId
# --------------------------------------------------------- #
function createSubnet {
    local subnetName="$1-subnet"
    local subnetId=$(aws ec2 describe-subnets \
        --filters "Name=tag-value,Values=$subnetName" \
        --query "Subnets[0].SubnetId")
    if [ "$subnetId" = "None" ]; then
        log "Creating a subnet..."
        subnetId=$(aws ec2 create-subnet \
            --vpc-id "$2" \
            --cidr-block 10.0.0.0/28 \
            --query 'Subnet.SubnetId')
        aws ec2 create-tags \
            --resources "$subnetId" \
            --tags Key=Name,Value="$subnetName"
    fi
    log "Your subnet id is: $subnetId"
    echo "$subnetId"
}

# --------------------------------------------------------- #
# createGateway ()                                          #
# An Internet gateway is a VPC component that allows communication
# between instances in your VPC and the Internet.
# Parameters: $instance_name
# --------------------------------------------------------- #
function createGateway {
    local gatewayName="$1-gateway"
    internetGatewayId=$(aws ec2 describe-internet-gateways \
        --filters "Name=tag-value,Values=$gatewayName" \
        --query "InternetGateways[0].InternetGatewayId")
    if [ "$internetGatewayId" = "None" ]; then
        log "Creating an internet gateway..."
        internetGatewayId=$(aws ec2 create-internet-gateway \
            --query 'InternetGateway.InternetGatewayId')
        aws ec2 create-tags \
            --resources "$internetGatewayId" \
            --tags Key=Name,Value="$gatewayName"
    fi
    log "Your gateway id is: $internetGatewayId"
    echo "$internetGatewayId"
}

# --------------------------------------------------------- #
# attachGateway()
# Create and attach an internet gateway, if needed.
# Parameters: $instance_name, $internetGatewayId, $vpcId
# --------------------------------------------------------- #
function attachGateway {
    local gatewayName="$1-gateway"
    attachedState=$(aws ec2 describe-internet-gateways \
        --filters "Name=tag-value,Values=$gatewayName" \
                  "Name=attachment.state,Values=available" \
        --query "InternetGateways[0].Attachments[0].State")
    if [ "$attachedState" != "available" ]; then
        log "Attaching gateway to VPC..."
        aws ec2 attach-internet-gateway \
            --internet-gateway-id "$2" \
            --vpc-id "$3"
    else
        log "Your gateway is already attached"
    fi
}

# --------------------------------------------------------- #
# createRouteTable ()                                       #
# Each subnet in your VPC must be associated with a route
# table; the table controls the routing for the subnet.
# Parameters: $instance_name, $vpcId, $internetGatewayId
# --------------------------------------------------------- #
function createRouteTable {
    local routeTableName="$1-route-table"
    local routeTableId=$(aws ec2 describe-route-tables \
        --filters "Name=tag-value,Values=$routeTableName" \
        --query "RouteTables[0].RouteTableId" )
    if [ "$routeTableId" = "None" ]; then
        log "Creating a new route table..."
        routeTableId=$(aws ec2 create-route-table \
            --vpc-id "$2" \
            --query 'RouteTable.RouteTableId')
        aws ec2 create-tags \
            --resources "$routeTableId" \
            --tags Key=Name,Value="$routeTableName"
        aws ec2 create-route \
            --route-table-id "$routeTableId" \
            --destination-cidr-block 0.0.0.0/0 \
            --gateway-id "$3"
    fi
    log "Your route table id is: $routeTableId"
    echo "$routeTableId"
}

# --------------------------------------------------------- #
# createRouteTableAssociation ()                            #
# Parameters: $instance_name, $routeTableId, $subnetId
# --------------------------------------------------------- #
function createRouteTableAssociation {
    local routeTableName="$1-route-table"
    local routeTableAssoc=$(aws ec2 describe-route-tables \
        --filters "Name=tag-value,Values=$routeTableName" \
        --query "RouteTables[0].Associations[0].RouteTableAssociationId")
    if [ "$routeTableAssoc" = "None" ]; then
        log "Associating your route table to your subnet..."
        routeTableAssoc=$(aws ec2 associate-route-table \
            --route-table-id "$2" \
            --subnet-id "$3")
    else
        log "Your route table is already associated with your subnet."
    fi
    echo "$routeTableAssoc"
}

# --------------------------------------------------------- #
# createSecurityGroup ()
# When you launch an instance, you associate one or more security groups with the instance.
# You add rules to each security group that allow traffic to or from its associated instances.
# Parameters: $instance_name, vpcId
# --------------------------------------------------------- #
function createSecurityGroup {
    groupName="$1-security-group"
    groupDescription="SG for $1"
    local securityGroupId=$(aws ec2 describe-security-groups \
        --filters "Name=description,Values=$groupDescription" \
        --query "SecurityGroups[0].GroupId")
    if [ "$securityGroupId" = "None" ]; then
        log "Creating a new security group..."
        securityGroupId=$(aws ec2 create-security-group \
            --group-name "$groupName" \
            --description "$groupDescription" \
            --vpc-id "$2" \
            --query 'GroupId')
        aws ec2 authorize-security-group-ingress \
            --group-id "$securityGroupId" \
            --protocol tcp \
            --port 22 \
            --cidr "0.0.0.0/0"
    fi
    log "Your security group id is: $securityGroupId"
    echo "$securityGroupId"
}

# --------------------------------------------------------- #
# createKeyFile ()
# Parameters: $instance_name
# --------------------------------------------------------- #
function createKeyFile {
    if [ ! -d ~/.ssh ]; then
        mkdir ~/.ssh
    fi
    key_name="aws-key-$1"
    key_file="~/.ssh/$key_name.pem"
    if [ ! -f "$key_file" ]; then
        log "Creating a new SSH key file..."
        aws ec2 create-key-pair \
            --key-name "$key_name" \
	        --query 'KeyMaterial' > "$key_file"
	    chmod 400 "$key_file"
    fi
    log "Your SSH key file is: $key_name"
    echo "$key_name"
}

# --------------------------------------------------------- #
# createInstance ()
# Parameters: $instance_name, $ami, $instanceType, aws-key-$name, $securityGroupId, $subnetId
# --------------------------------------------------------- #
function createInstance {
    instanceName="$1-gpu-machine"
    instanceId=$(aws ec2 describe-instances \
        --query "Reservations[0].Instances[0].InstanceId" \
        --filter "Name=tag-value,Values=$instanceName")
    if [ "$instanceId" = "None" ] || [ "$(aws ec2 describe-instances \
        --query "Reservations[0].Instances[0].State.Name" \
        --instance-ids $instanceId)" = "terminated" ]; then
        log "Creating a new $3 instance..."
        instanceId=$(aws ec2 run-instances \
            --image-id "$2" \
            --count 1 \
            --instance-type "$3" \
            --key-name "$4" \
            --security-group-ids "$5" \
            --subnet-id "$6" \
            --associate-public-ip-address \
            --block-device-mapping file://config/ebs_config.json \
            --query 'Instances[0].InstanceId')
        aws ec2 create-tags \
            --resources "$instanceId" \
            --tags Key=Name,Value="$instanceName"
        aws ec2 wait instance-running --instance-ids "$instanceId"
        aws ec2 wait instance-status-ok  --instance-ids "$instanceId"
        sleep 10 # wait for ssh service to start running too
    else
        log "An instance that has not been terminated already exists."
        exit 1
        # TODO: start the instance
    fi
    log "Your instance id is: $instanceId"
    echo "$instanceId"
}

# --------------------------------------------------------- #
# getAssociationId ()
# Parameters: $instanceId
# --------------------------------------------------------- #
function getAssociationId {
    instanceName="$1-gpu-machine"
    assocId=$(aws ec2 describe-addresses \
        --filters "Name=instance-id,Values=$1" \
        --query "Addresses[0].AssociationId")
    if [ "$assocId" = "None" ]; then
        log "Allocating an association address..."
        allocAddr=$(aws ec2 allocate-address \
            --domain vpc \
            --query 'AllocationId')
        assocId=$(aws ec2 associate-address \
            --instance-id $1 \
            --allocation-id $allocAddr \
            --query 'AssociationId')
    fi
    log "Your association id is: $assocId"
    echo "$assocId"
}

# --------------------------------------------------------- #
# getInstanceIP ()
# Parameters: $instanceId
# --------------------------------------------------------- #
function getInstanceIP {
    instanceIP=$(aws ec2 describe-instances \
        --query "Reservations[0].Instances[0].PublicDnsName" \
        --instance-ids "$1")
    log "Your instance's IP is: $instanceIP"
    echo "$instanceIP"
}
