zone=$(aws ec2 describe-instances \
    --instance-ids $instanceId \
    --query "Reservations[0].Instances[0].Placement.AvailabilityZone")

if [ -e "$name-snapshot.sh" ]
  then
    . $(dirname "$0")/$name-snapshot.sh
    echo "Creating volume from snapshot: $snapshotId"
    volumeId=$(aws ec2 create-volume \
        --snapshot-id $snapshotId \
        --volume-type gp2 \
        --size 128 \
        --availability-zone $zone \
        --query "VolumeId")
else
  echo 'No snapshots, creating a new volume...'
  volumeId=$(aws ec2 create-volume \
    --availability-zone $zone \
    --volume-type gp2 \
    --size 128 \
    --query "VolumeId")
  devicePath="/dev/sda1"
fi

aws ec2 wait volume-available --volume-ids $volumeId
echo "Starting up instance: $instanceId, with volume: $volumeId, device: $devicePath"
aws ec2 attach-volume --instance-id $instanceId --volume-id $volumeId --device $devicePath
aws ec2 start-instances --instance-ids $instanceId
aws ec2 wait instance-running --instance-ids $instanceId

# TODO: delete the snapshot after loading it to save space
