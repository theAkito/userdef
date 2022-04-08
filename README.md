[![nimble](https://raw.githubusercontent.com/yglukhov/nimble-tag/master/nimble.png)](https://nimble.directory/pkg/userdef)

[![Source](https://img.shields.io/badge/project-source-2a2f33?style=plastic)](https://github.com/theAkito/userdef)
[![Language](https://img.shields.io/badge/language-Nim-orange.svg?style=plastic)](https://nim-lang.org/)

![Last Commit](https://img.shields.io/github/last-commit/theAkito/userdef?style=plastic)

[![GitHub](https://img.shields.io/badge/license-GPL--3.0-informational?style=plastic)](https://www.gnu.org/licenses/gpl-3.0.txt)
[![Liberapay patrons](https://img.shields.io/liberapay/patrons/Akito?style=plastic)](https://liberapay.com/Akito/)

## What
This tool is a more advanced `adduser` / `useradd` for your [Alpine](https://www.alpinelinux.org/) and [BusyBox](https://www.busybox.net/) based Docker images.

For example, this tool may create a custom OS user with a custom ID inside pre-made Docker images, which perhaps already have a custom user defined and rebuilding the Docker image just to have your custom user in it is not an option.

## Why
### Reason 1
Now, more and more server apps try to go with the current meta of being available on Kubernetes, etc. This is a good idea, however it's often not well executed.
Almost all of the popular server apps are not cloud-native. Their structure is still of some legacy kind.
Examples are [Mattermost](https://mattermost.com/), [Gitea](https://gitea.io/en-us/), [Nextcloud](https://nextcloud.com/).
These server apps have Helm Charts available. However, applying best practices, especially the ones regarding security are not easy to achieve.
Especially, when talking about the `podSecurityContext`. The `fsGroup` option is either not respected properly, which leads to broken deployments, or it's not even available and you have to add it yourself to the Helm Chart.

For example, take the Gitea Helm Chart as an example. You are allowed to set the `podSecurityContext`:
https://gitea.com/gitea/helm-chart/src/commit/d94226765d6e1f197a3112e1b1abbcd73a8bea33/values.yaml#L19-L20

But, if you provide your custom `fsGroup` value, then the deployment will be broken. Why?
https://github.com/go-gitea/gitea/blob/66f2210feca0b50d305a46a203c2b3d2f4d3790b/Dockerfile.rootless#L39-L48

Because the user and group ID of `1000` is hard-coded into the Docker image.

Now, imagine you have an `sshfs` mount, which requires you using the user of the ID `9234`.
The hard-coded `1000` inside the image breaks usage of this `sshfs` mount, just because it does not let you define a custom user with a custom ID.

To make all this work more smoothly, this tool aims to delete the existing user in that Docker image and then recreate it with *your* custom user, which has an ID defined by *you*, instead of being forced to use the randomly chosen hard-coded user ID.

### Reason 2

You may just as well use this tool as a better `adduser` where the actual `adduser` or `useradd` (like the one in [Alpine](https://www.alpinelinux.org/)) have arbitrary and unnecessary restrictions, like for example [limiting the UID/GID size to 256000](https://stackoverflow.com/q/41807026/7061105).

## How
Example using the rootless Docker image for Gitea:

[//]: # (https://github.com/microsoft/vscode/issues/95728#issuecomment-616782131)
```dockerfile
## Get the binary.
## The default Docker Tag provides the Alpine (musl) based binary.
FROM akito13/userdef AS base
## Pull the image you want to modify the executing user of.
FROM gitea/gitea:1.16.5-linux-amd64-rootless

## We temporarily need to use the root user,
## as we are doing administrative tasks, like e.g. modifying an OS user.
USER root:root
COPY --from=base /userdef /userdef
## 1. Change the existing user.
## 2. Use that user to `chown` relevant folders.
## 3. Remove the binary, because the user has been changed,
##    i.e. our job is done here.
RUN /userdef -h=/var/lib/gitea/git -n=git -u=9234 -g=9234 && \
  chown git:git -R /var/lib/gitea /etc/gitea && \
  rm -f /userdef

## Switch to the now relevant executing user.
USER 9234:9234
## Taken from https://github.com/go-gitea/gitea/blob/66f2210feca0b50d305a46a203c2b3d2f4d3790b/Dockerfile.rootless#L71-L72
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD []
```

This way, you get the behaviour of the original Docker image, but instead being forced to use the hard-coded user ID, you adjust the user inside the image to the one *you* specify.

For a live example, run `nimble example`.

### CLI Usage
```
Usage:
  userdef -n=<user-name> -u=<user-id> -h=<user-home>
          [-g=<user-group-id>] [-l | -l=[true|false]]
          [-c=<path-to-config-file> | <path-to-config-file>]

Examples:
  userdef --help
  userdef -h=/var/lib/gitea/git -n=git -u=9234 -g=9234
  userdef -h=/home/langlang -n=langlang -u=290111 -g=290111 --long
  userdef -h=/overwrites/home/value/in/userdef.json -l=true /path/to/userdef.json

Options:
  -n, --name            Name of the user to modify or add.
  -u, --uid             User ID.
  -h, --home            Path to user's home.
  -c, --config          (Optional) Provide path to configuration file.
  -g, --gid             (Optional) Group ID. If empty, then GID will be same as UID.
  -l, --long            (Optional) Whether long IDs (greater than 256000) are guaranteed to be supported.
  -v, --version         App version information.
  --help                This help text.

Hints:
  * If a user with the provided name already exists,
    then it will be deleted and a new one will be created,
    to replace the original one.

  * Providing a configuration file works by using the `--config` option or
    by providing the path without using any option.

  * You may replace the equal signs with colons when providing CLI arguments.
    Example: userdef -h:/home/langlang -n:langlang -u:290111 -g:290111 --long

  * You also may replace the equal signs with nothing when providing CLI arguments.
    Example: userdef -h/home/langlang -nlanglang -u290111 -g290111 --long
```

## Where
Docker containers running Docker images based on Linux.
You will need it most likely on BusyBox based images, like Alpine.

## Goals
* Reliability

## Project Status
Stable Beta.

This app is well tested & works, but needs more testing and feedback from 3rd parties. --> Please help!

## TODO
* ~~Make ID adjustable~~
* ~~Make Name adjustable~~
* ~~Read from config.json~~
* ~~Support long and short IDs~~
* ~~Add base Dockerfile~~
* ~~Add support for multi-arch Docker image~~
* ~~Add some kind of Continuous Delivery for binary in Docker image~~
* ~~Add meaningful example in README~~
* ~~Add libc based Docker images for binary provision (Alpine is musl based)~~
* ~~Add CLI Usage Info to README~~
* ~~Publish to Nimble~~
* ~~Publish to [Awesome Docker](https://github.com/veggiemonk/awesome-docker)~~
* ~~Use Nimscript instead of Bash for Build scripts~~
* ~~Add `nim.cfg` for optimised `nimble install` build~~
* ~~Test with GID different from UID~~
* Add Github Release
* Provide BUILD_VERSION, BUILD_REVISION, BUILD_DATE in Docker Release images
* Add meaningful practical examples
* Parse root Dockerfile and extract correct original user ID and user name

## License
Copyright © 2022  Akito <the@akito.ooo>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.