# Launch a p2.xlarge instance on AWS

### Inspiration

This project is based on the [setup_instance.sh](https://github.com/fastai/courses/blob/master/setup/setup_instance.sh) that is part of the first [fast.ai](http://course.fast.ai/) course. The wiki page for the original instructions is [here](http://wiki.fast.ai/index.php/AWS_install).

### Differences

1. The original script configures AWS to use a `default` profile. This command line tool allows you to launch an instance under any AWS profile that is configured on your system.
2. The original script creates a number of required things (e.g., a VPC, a route table, etc.). This tool is idempotent; it checks for the existence of those components and does not create them if they exist.
3. I've set it to use an [Amazon Linux Conda AMI](https://aws.amazon.com/marketplace/pp/B077GF11NF) in `eu-west-1`.

### Limitations

* This tool does not currently launch a Jupyter notebook on the instance.
* There are a variety of other `TODO`s in the code.
* Not everything has been thoroughly tested.

## Create the Instance

If you are running this for the first time, make sure you have completed the [one time setup steps](Setup.md).

To launch an instance, type:

```bash
$ ./setup_p2.sh <profile-name>
```

Where `<profile-name>` is the profile you created when configuring your AWS CLI (leave blank to use the `default` profile). 

By default:
* `<name>` is set to `gpu-machine` for `p2.xlarge` instances, `test-machine` otherwise.
* `<istance-type>` is set to `p2.xlarge`

This will produce files like this:
* `<name>-connect.sh` to connect to your instance.
* `<name>-sftp.sh` to FTP to your instance.
* `<name>-reboot.sh` to reboot your instance (untested).
* `<name>-start.sh` to start your instance and create/restore an EBS volume from a snapshot.
* `<name>-stop.sh` to stop your instance and detach/store your EBS volume as a snapshopt.
* `<name>-variables.sh` to export all of the variables created throughout the installation.
* `<name>-uninstall.sh` to remove everything that has been created from AWS.
