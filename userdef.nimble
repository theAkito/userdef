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
import os, strformat, strutils
let params = if paramCount() > 8: commandLineParams()[8..^1] else: @[]

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
task release_docker, "Deploy Docker image release. Provide a Semver Version as the first argument to this task.":
  exec &"nim e tasks/docker_build.nims {params.join(\" \")}"
task example, "Run example Docker build.":
  let fresh = params[^1]
  exec &"nim e tests/test_build_docker_gitea.nims {fresh}"
task makecfg, "Create nim.cfg for optimized builds.":
  exec "nim helpers/cfg_optimized.nims"
task clean, "Removes nim.cfg.":
  exec "nim helpers/cfg_clean.nims"
