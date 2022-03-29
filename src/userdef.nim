import
  userdef/[
    meta,
    utils
  ],
  std/[
    logging,
    strutils,
    os,
    osproc,
    posix,
    sequtils
  ]

let logger = newConsoleLogger(defineLogLevel(), logMsgPrefix & logMsgInter & "master" & logMsgSuffix)

proc run() =
  let
    passwdContent = utils.readLines(passwdPath)
    groupContent = utils.readLines(groupPath)
    passwdContentClean = passwdContent.filterNotContains("git")
    groupContentClean = groupContent.filterNotContains("git")
  passwdPath.writeFile(passwdContentClean.join(lineEnd))
  groupPath.writeFile(groupContentClean.join(lineEnd))
  #[ Initialise configuration file. ]#
  #if not initConf(configPath): raise OSError.newException("Config file could neither be found nor generated!")

when isMainModule:
  # logger.log(lvlInfo, "Starting with the following configuration:\n" & pretty(%* config))
  run()