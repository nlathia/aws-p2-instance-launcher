volumeId=$(aws ec2 describe-volumes \
    --filters "Name=attachment.instance-id,Values=$instanceId"\
    --query "Volumes[0].VolumeId")

aws ec2 stop-instances --instance-ids $instanceId
aws ec2 wait instance-stopped --instance-ids $instanceId

if [ "$volumeId" != "None" ]
  then
    devicePath=$(aws ec2 describe-volumes \
        --filters "Name=attachment.instance-id,Values=$instanceId" \
        --query "Volumes[0].Attachments[0].Device")
    snapshotId=$(aws ec2 create-snapshot \
        --volume-id $volumeId \
        --query "SnapshotId")

    aws ec2 detach-volume --volume-id $volumeId
    aws ec2 delete-volume --volume-id $volumeId
    echo export snapshotId=$snapshotId > $name-snapshot.sh
    echo export instanceId=$instanceId >> $name-snapshot.sh
    echo export devicePath=$devicePath >> $name-snapshot.sh
    echo "Storing snapshot id: $snapshotId to $name-snapshot.sh"
    chmod u+x $name-snapshot.sh
fi
