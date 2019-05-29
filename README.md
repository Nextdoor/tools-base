# nextdoor/tools-base

## Description

Base docker image for Nextdoor tools containers which
are designed to volume mount a working directory on the host and
to run tools against that directory as an unprivileged user.

## Details

The container provides two unprivileged users, `tool` and `user`,
along with `/tool` and `/work` directories.

The `tool` user has ownership of the `/tool` directory and is responsible
for the installation of tools in that directory at image build time.

The `user` user has ownership of the `/work` directory, which is
volume mounted from the host.  The `user` user and corresponding group
is modified in the container entrypoint to match the UID:GID of the
work directory so as to match the ownership of that directory on the host.
In addition the files in the `user` home directory are also chowned to
match the new UID:GID.  The `user` user should not own files outside
of its home directory, or they will be orphaned after the ownership change.

## Usage

Shell with current directory as working directory:

```docker run -v `pwd`:/work/target -it nextdoor/tools-base:latest /bin/bash```

Shell as `tool` user (skips ownership update for `user`):

```docker run --user tool -v `pwd`:/work/target -it nextdoor/tools-base:latest /bin/bash```

Use the `--user` option with `exec` on a running container to get additional shells, including as root, if necessary.
