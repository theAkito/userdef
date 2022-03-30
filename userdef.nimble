# Package

version       = "0.1.0"
author        = "Akito <the@akito.ooo>"
description   = "Creates and sets up custom OS user of any ID for pre-made Docker images to increase Docker security."
license       = "GPL-3.0-or-later"
srcDir        = "src"
bin           = @["userdef"]
skipDirs      = @["tasks"]
skipFiles     = @["README.md"]
skipExt       = @["nim"]


# Dependencies

requires "nim >= 1.6.4"


# Tasks

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
            --opt:speed \
            --out:userdef \
            src/userdef
       """
task dbuild, "Debug Build project.":
  exec """nim c \
            --define:debug:true \
            --debuginfo:on \
            --out:userdef_debug \
            src/userdef
       """
task example, "Run example Docker build.":
  exec "bash test_build-docker-gitea.sh"
task makecfg, "Create nim.cfg for optimized builds.":
  exec "nim tasks/cfg_optimized.nims"
task clean, "Removes nim.cfg.":
  exec "nim tasks/cfg_clean.nims"
