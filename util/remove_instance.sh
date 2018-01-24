#!/bin/bash

echo "Terminating instance..."
aws ec2 terminate-instances --instance-ids $instanceId
aws ec2 wait instance-terminated --instance-ids $instanceId

echo "Deleting security group..."
aws ec2 delete-security-group --group-id $securityGroupId

echo "Releasing address.."
aws ec2 disassociate-address --association-id $assocId
aws ec2 release-address --allocation-id $allocAddr

echo "Deleting route table..."
aws ec2 disassociate-route-table --association-id $routeTableAssoc
aws ec2 delete-route-table --route-table-id $routeTableId

echo "Deleting the internet gateway..."
aws ec2 detach-internet-gateway \
    --internet-gateway-id $internetGatewayId \
    --vpc-id $vpcId
aws ec2 delete-internet-gateway \
    --internet-gateway-id $internetGatewayId

echo "Deleting the subnet..."
echo aws ec2 delete-subnet --subnet-id $subnetId

echo "Deleting the VPC..."
echo aws ec2 delete-vpc --vpc-id $vpcId

echo "Removing local shortcuts..."
echo rm $name-*.sh

echo "If you want to delete the key-pair, please do it manually."
