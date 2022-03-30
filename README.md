[![nimble](https://raw.githubusercontent.com/yglukhov/nimble-tag/master/nimble.png)](https://nimble.directory/pkg/userdef)

[![Source](https://img.shields.io/badge/project-source-2a2f33?style=plastic)](https://github.com/theAkito/userdef)
[![Language](https://img.shields.io/badge/language-Nim-orange.svg?style=plastic)](https://nim-lang.org/)

![Last Commit](https://img.shields.io/github/last-commit/theAkito/userdef?style=plastic)

[![GitHub](https://img.shields.io/badge/license-GPL--3.0-informational?style=plastic)](https://www.gnu.org/licenses/gpl-3.0.txt)
[![Liberapay patrons](https://img.shields.io/liberapay/patrons/Akito?style=plastic)](https://liberapay.com/Akito/)

## What
This tool creates a custom OS user with a custom ID inside pre-made Docker images, which perhaps already have a custom user defined and rebuilding the Docker image just to have your custom user in it is not an option.

## Why
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

## How
Example using the rootless Docker image for Gitea:

[//]: # (https://github.com/microsoft/vscode/issues/95728#issuecomment-616782131)
```dockerfile
FROM gitea/gitea:1.16.5-linux-amd64-rootless

#TODO: Download `userdef` here or get from previous build step...
COPY myuserconfig.json /
RUN userdef myuserconfig.json

# Taken from https://github.com/go-gitea/gitea/blob/66f2210feca0b50d305a46a203c2b3d2f4d3790b/Dockerfile.rootless#L71-L72
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD []
```

This way, you get the behaviour of the original Docker image, but instead being forced to use the hard-coded user ID, you adjust the user inside the image to the one *you* specify.

At first, only specifying the user ID will be supported, as this is the most important thing.
The user name is not technically important, but could be important for maintenance and ease of user reasons.

## Where
Docker containers running Docker images based on Linux.

## Goals
* Reliability

## Project Status
Before Pre-Alpha. Unstable API of the configuration file.

## TODO
* ~~Make ID adjustable~~
* ~~Make Name adjustable~~
* ~~Read from config.json~~
* ~~Support long and short IDs~~
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