# Package

version       = "0.5.0"
author        = "Akito <the@akito.ooo>"
description   = "A more advanced adduser for your Alpine based Docker images."
license       = "GPL-3.0-or-later"
srcDir        = "src"
bin           = @["userdef"]
skipDirs      = @["tasks"]
skipFiles     = @["README.md"]
skipExt       = @["nim"]


# Dependencies

requires "nim     >= 1.6.4"
requires "useradd >= 0.3.0"


# Tasks
import os, strformat, strutils, distros
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
  var version = if params.len > 0: params[^1] else: ""
  if version.isEmptyOrWhitespace: version = "unreleased"
  var revision = gorgeEx("""git log -1 --format="%H"""")[0]
  var date = if Alpine.detectOs: gorgeEx("""date""")[0] else: gorgeEx("""date --iso-8601=seconds""")[0]
  exec &"""nim c \
            --define:appVersion:{version} \
            --define:appRevision:{revision} \
            --define:appDate:"{date}" \
            --define:danger \
            --passL="-lcrypt" \
            --opt:size \
            --out:userdef \
            src/userdef && \
          strip userdef \
            --strip-all \
            --remove-section=.comment \
            --remove-section=.note.gnu.gold-version \
            --remove-section=.note \
            --remove-section=.note.gnu.build-id \
            --remove-section=.note.ABI-tag
       """
task dbuild, "Debug Build project.":
  var version = if params.len > 0: params[^1] else: ""
  if version.isEmptyOrWhitespace: version = "unreleased"
  var revision = gorgeEx("""git log -1 --format="%H"""")[0]
  var date = if Alpine.detectOs: gorgeEx("""date""")[0] else: gorgeEx("""date --iso-8601=seconds""")[0]
  exec &"""nim c \
            --define:appVersion:{version} \
            --define:appRevision:{revision} \
            --define:appDate:"{date}" \
            --define:debug:true \
            --passL="-lcrypt" \
            --debuginfo:on \
            --out:userdef_debug \
            src/userdef
       """
task release_docker, "Deploy Docker image release. Provide a Semver Version as the first argument to this task.":
  exec &"nim e tasks/docker_build.nims {params.join(\" \")}"
task example, "Run example Docker build.":
  let fresh = if params.len > 0: params[^1] else: "false"
  exec &"nim e tests/test_build_docker_gitea.nims {fresh}"
task test_version, "Test version display.":
  exec "nimble dbuild && ./userdef_debug -v && nimble fbuild && ./userdef -v"