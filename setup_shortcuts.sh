#!/bin/bash
#
# These functions are called in ../launch.sh

# --------------------------------------------------------- #
# writeConnectionShortcuts ()
# Util to SSH and SFTP to your instance
# Parameters: $instance_name, $key_file, $instanceIP
# --------------------------------------------------------- #
function writeConnectionShortcuts {
    output="$1-connect.sh"
    echo "#!/bin/bash" > "$output"
    echo "# Connect to your instance:" >> "$output"
    echo "ssh -i ~/.ssh/$2 ec2-user@$3" >> "$output"
    echo "" >> "$output"

    output="$1-sftp.sh"
    echo "#!/bin/bash" > "$output"
    echo "# FTP to your instance:" >> "$output"
    echo "sftp -i ~/.ssh/$2 ec2-user@$3" >> "$output"
    echo "" >> "$output"
}

# --------------------------------------------------------- #
# writeStateShortcuts ()
# Shortcuts to start, stop, reboot your instance
# Parameters: $instance_name, $instanceId
# --------------------------------------------------------- #
function writeStateShortcuts {
    output="$1-stop.sh"
    echo "#!/bin/bash" > "$output"
    echo "# Stop your instance:" >> "$output"
    echo "instanceId=$2" >> "$output"
    cat ./util/stop_instance.sh >> "$output"

    output="$1-start.sh"
    echo "#!/bin/bash" > "$output"
    echo "# Start your instance:" >> "$output"
    echo "instanceId=$2" >> "$output"
    cat ./util/start_instance.sh >> "$output"

    output="$1-reboot.sh"
    echo "#!/bin/bash" > "$output"
    echo "# Reboot your instance:" >> "$output"
    echo "aws ec2 reboot-instances --instance-ids $2"  >> "$output"
}

# --------------------------------------------------------- #
# writeUninstall ()
# Shortcuts to remove everything from AWS
# Parameters: $instance_name, AWS_PROFILE, $instanceId, $securityGroupId, assocId, allocAddr, routeTableAssoc, routeTableId, internetGatewayId, vpcId, subnetId
# --------------------------------------------------------- #
function writeUninstall {
    output="$1-uninstall.sh"
    echo "#!/bin/bash" > "$output"
    echo "# Remove everything:" > "$output"

    echo "export AWS_PROFILE=$2" >> "$output"
    echo "instanceId=$3" >> "$output"
    echo "securityGroupId=$4" >> "$output"
    echo "assocId=$5" >> "$output"
    echo "allocAddr=$6" >> "$output"
    echo "routeTableAssoc=$7" >> "$output"
    echo "routeTableId=$8" >> "$output"
    echo "internetGatewayId=$9" >> "$output"
    echo "vpcId=${10}" >> "$output"
    echo "subnetId=${11}" >> "$output"

    cat ./util/remove_instance.sh >> "$output"
}
