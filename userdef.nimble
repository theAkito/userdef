# Package

version       = "0.1.0"
author        = "Akito <the@akito.ooo>"
description   = "A more advanced adduser for your Alpine based Docker images."
license       = "GPL-3.0-or-later"
srcDir        = "src"
bin           = @["userdef"]
skipDirs      = @["tasks"]
skipFiles     = @["README.md"]
skipExt       = @["nim"]


# Dependencies

requires "nim >= 1.6.4"


# Tasks
import os, strformat
let params = commandLineParams()

task intro, "Initialize project. Run only once at first pull.":
  exec "git submodule add https://github.com/theAkito/nim-tools.git tasks || true"
  exec "git submodule update --init --recursive"
  exec "git submodule update --recursive --remote"
  exec "nimble configure"
task configure, "Configure project. Run whenever you continue contributing to this project.":
  exec "git fetch --all"
  exec "nimble check"
  exec "nimble --silent refresh"
  exec "nimble install --accept --depsOnly"
  exec "git status"
task fbuild, "Build project.":
  exec """nim c \
            --define:danger \
            --opt:size \
            --out:userdef \
            src/userdef && \
          strip userdef
       """
task dbuild, "Debug Build project.":
  exec """nim c \
            --define:debug:true \
            --debuginfo:on \
            --out:userdef_debug \
            src/userdef
       """
task releaseDocker, "Deploy Docker image release. Provide a Semver Version as the first argument to this task.":
  let version = params[^1]
  exec &"bash docker-build.sh {fresh}"
task example, "Run example Docker build.":
  let fresh = params[^1]
  exec &"bash test_build-docker-gitea.sh {fresh}"
task makecfg, "Create nim.cfg for optimized builds.":
  exec "nim tasks/cfg_optimized.nims"
task clean, "Removes nim.cfg.":
  exec "nim tasks/cfg_clean.nims"
