#!/bin/bash
#########################################################################
# Copyright (C) 2022 Akito <the@akito.ooo>                              #
#                                                                       #
# This program is free software: you can redistribute it and/or modify  #
# it under the terms of the GNU General Public License as published by  #
# the Free Software Foundation, either version 3 of the License, or     #
# (at your option) any later version.                                   #
#                                                                       #
# This program is distributed in the hope that it will be useful,       #
# but WITHOUT ANY WARRANTY; without even the implied warranty of        #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the          #
# GNU General Public License for more details.                          #
#                                                                       #
# You should have received a copy of the GNU General Public License     #
# along with this program.  If not, see <http://www.gnu.org/licenses/>. #
#########################################################################


version="$1"
tag="$2"
tagSuffixDebug="-debug"

if [[ -z "${tag}" ]]; then
  tag="akito13/userdef:${1}"
fi

docker \
  buildx \
  build \
    --no-cache \
    --platform linux/amd64,linux/i386,linux/arm64,linux/arm/v7,linux/arm32v5,linux/arm32v6,linux/arm32v7,linux/arm64v8 \
    --tag "${tag}${tagSuffixDebug}" \
    --tag "$(printf '%s%s' "${tag%:*}" ":latest${tagSuffixDebug}")" \
    --file debug.Dockerfile \
    --push \
  .