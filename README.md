## Overview

Docker container for [s3backer](https://github.com/archiecobbs/s3backer) by
Archie Cobbs. 

The basic workflow is to use s3backer to expose a virtual file backed by Amazon
S3. You can then mount a normal file system (e.g., ext4, xfs, etc) on top of
this virtual file as a loopback device.


You can use a container based on this image almost as a drop-in alternative to
using a s3backer binary directly on the host machine. 

A docker image is available on Docker Hub. You can get it with:

	docker pull adamaymas/s3backer_docker

You can also build it yourself using the Dockerfile available at:
[https://github.com/adamay909/s3backer_docker/](https://github.com/adamay909/s3backer_docker/).

## Basic Usage

FUSE support in the kernel is required which should not be a problem for most Linux distros.
When in doubt, do

	modprobe fuse

before attempting to use the image.

You can start a container with

	docker run <OPTIONS> adamaymas/s3backer_docker <S3BACKER_OPTIONS+ARGUMENTS>

Inside the container, this will simply run 

	s3backer -f <S3BACKER_OPTIONS+ARGUMENTS>

The -f is to keep the process in the foreground so as to prevent the container from
exiting immediately. If you start the container without any S3BACKER_OPTIONS+ARGUMENTS, it will
display the help message for s3backer and exit.

The main difference between using the plain s3backer binary and this image is
that this image will mount the S3 backed file inside the container and you need
to take steps to make it available to the host (assuming you want to access it
from the host). You also need to make the files containing your S3 credentials
available to the container. Both can be achieved by appropriate options for
docker run.  


E.g., to create and/or mount an S3 bucket as an S3 backed file, do:

	docker run --rm -d \
	-v <PATH_TO_CREDENTIALS_FILE>:/root/.s3backer_passwd\
	-v <HOST_MOUNTPOINT>:/s3b:shared \
	--device /dev/fuse \
	--cap-add SYS_ADMIN \
	adamaymas/s3backer_docker \
	<S3BACKER_OPTIONS> <BUCKET> /s3b



Consult the [s3backer
documentation](https://github.com/archiecobbs/s3backer/wiki)  for the needed
S3BACKER_OPTIONS for creating an S3 backed file, etc. For the S3 backed file to
be useful, you will need some additional steps (i.e., create a file system
inside the file and mount it). Consult the s3backer
documentation!

The mount point for the s3backer file inside the container is /s3b.  A host
directory is bind mounted there with the shared flag so that the s3backer file
is visible from the host in the host directory.  The docker daemon might
complain about the shared flag.  In that case, you will have to make the
relevant host file system shared. You can do that with:

	mount --make-shared filesystem

See [https://www.kernel.org/doc/Documentation/filesystems/sharedsubtree.txt](https://www.kernel.org/doc/Documentation/filesystems/sharedsubtree.txt) for what this is about. I do something like:

	mkdir -p /mnt/s3backer &&\
	mount -t tmpfs tmpfs /mnt/s3backer &&\
	mount --make-shared /mnt/s3backer

and then use subdirectories of /mnt/s3backer as mountpoints of s3backer. 

You can unmount the s3backer file by simply:

	umount HOST_MOUNTPOINT

This will also terminate the docker container. This is expected behaviour. The
container runs exactly one process---s3backer---and the umount command causes
the s3backer process to exit, and that in turn makes the container exit since a
container exits when its main process exits. Do NOT use 'docker stop ...' as
that will end up killing the s3backer process without unmounting the bucket cleanly.


## Notes

I created this so I can quickly get s3backer running on various distros without
having to hunt down dependencies for building and running s3backer: just
install Docker. If you are going to use s3backer on a more permanent basis, you
are probably better off building and running s3backer on the host system.
That will avoid the Docker overhead. Consult the s3backer [documentations](https://github.com/archiecobbs/s3backer/wiki/Build-and-Install) for information on building from source.

You need administrator privileges for running most (all) of the commands above. Use sudo or su as appropriate to your system.

The Dockerfile for this image will build s3backer using Alpine Linux.




