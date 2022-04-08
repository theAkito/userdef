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
#
#################################   Boilerplate of the Boilerplate   ####################################################
# Coloured Echoes                                                                                                       #
function red_echo      { echo -e "\033[31m$@\033[0m";   }                                                               #
function green_echo    { echo -e "\033[32m$@\033[0m";   }                                                               #
function yellow_echo   { echo -e "\033[33m$@\033[0m";   }                                                               #
function white_echo    { echo -e "\033[1;37m$@\033[0m"; }                                                               #
# Coloured Printfs                                                                                                      #
function red_printf    { printf "\033[31m$@\033[0m";    }                                                               #
function green_printf  { printf "\033[32m$@\033[0m";    }                                                               #
function yellow_printf { printf "\033[33m$@\033[0m";    }                                                               #
function white_printf  { printf "\033[1;37m$@\033[0m";  }                                                               #
# Debugging Outputs                                                                                                     #
function white_brackets { local args="$@"; white_printf "["; printf "${args}"; white_printf "]"; }                      #
function echoDebug  { local args="$@"; if [[ ${debug_flag} == true ]]; then                                             #
white_brackets "$(white_printf   "DEBUG")" && echo " ${args}"; fi; }                                                    #
function echoInfo   { local args="$@"; white_brackets "$(green_printf  "INFO" )"  && echo " ${args}"; }                 #
function echoWarn   { local args="$@"; white_brackets "$(yellow_printf "WARN" )"  && echo " ${args}" 1>&2; }            #
function echoError  { local args="$@"; white_brackets "$(red_printf    "ERROR")"  && echo " ${args}" 1>&2; }            #
# Silences commands' STDOUT as well as STDERR.                                                                          #
function silence { local args="$@"; ${args} &>/dev/null; }                                                              #
# Check your privilege.                                                                                                 #
function checkPriv { if [[ "$EUID" != 0 ]]; then echoError "Please run me as root."; exit 1; fi;  }                     #
# Returns 0 if script is sourced, returns 1 if script is run in a subshell.                                             #
function checkSrc { (return 0 2>/dev/null); if [[ "$?" == 0 ]]; then return 0; else return 1; fi; }                     #
# Prints directory the script is run from. Useful for local imports of BASH modules.                                    #
# This only works if this function is defined in the actual script. So copy pasting is needed.                          #
function whereAmI { printf "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )";   }                     #
# Alternatively, this alias works in the sourcing script, but you need to enable alias expansion.                       #
alias whereIsMe='printf "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"'                            #
debug_flag=false                                                                                                        #
#########################################################################################################################

version="$1"
tag="$2"
platforms="linux/amd64,linux/i386,linux/arm64,linux/arm/v7,linux/arm32v5,linux/arm32v6,linux/arm32v7,linux/arm64v8"
tagUbuntu="ubuntu"
tagAlpine="alpine"
tagLibc="libc"
tagMusl="musl"
tagSuffixLibc="-${tagLibc}"
tagSuffixMusl="-${tagMusl}"

if [[ -z "${tag}" ]]; then
  tag="akito13/userdef:$1"
fi

docker \
  buildx \
  build \
    --platform "${platforms}" \
    --tag "${tag}" \
    --tag "${tag}${tagSuffixMusl}" \
    --tag "$(printf '%s%s' "${tag%:*}" ":latest")" \
    --tag "$(printf '%s%s' "${tag%:*}" ":latest${tagSuffixMusl}")" \
    --tag "$(printf '%s%s' "${tag%:*}" ":${tagMusl}")" \
    --tag "$(printf '%s%s' "${tag%:*}" ":${tagAlpine}")" \
    --file Dockerfile \
    --push \
  .

docker \
  buildx \
  build \
    --platform "${platforms}" \
    --tag "${tag}${tagSuffixLibc}" \
    --tag "$(printf '%s%s' "${tag%:*}" ":latest${tagSuffixLibc}")" \
    --tag "$(printf '%s%s' "${tag%:*}" ":${tagLibc}")" \
    --tag "$(printf '%s%s' "${tag%:*}" ":${tagUbuntu}")" \
    --file libc.Dockerfile \
    --push \
  .