import
  userdef/[
    meta,
    utils,
    configurator
  ],
  std/[
    options,
    json,
    parseopt,
    strformat,
    times,
    logging,
    strutils,
    os
  ]

let
  logger = newConsoleLogger(defineLogLevel(), logMsgPrefix & logMsgInter & "master" & logMsgSuffix)
  timestamp = now().toTime.toUnix div 60 div 60 div 24
  invalidId = -1
var
  thisConfigPath = ""
  home = ""
  name = ""
  uid = invalidId
  gid = invalidId

template optSetConfigPath() =
  logger.log(lvlInfo, "Config path provided: " & val)
  thisConfigPath = val
  thisConfigPath.raiseIfNotExists

proc raiseIfNotExists(filePath: string) =
  if not filePath.fileExists:
    raise OSError.newException("Path to config file provided is not a real file or cannot be found! Path to file provided: " & filePath)

proc setOpts() =
  for kind, key, val in commandLineParams().getopt():
    case kind
      of cmdArgument:
        optSetConfigPath()
      of cmdLongOption, cmdShortOption:
        case key
          of "c", "config":
            optSetConfigPath()
          of "h", "home":
            logger.log(lvlInfo, "User home provided: " & val)
            home = val
          of "n", "name":
            logger.log(lvlInfo, "User Name provided: " & val)
            name = val
          of "u", "uid":
            logger.log(lvlInfo, "User ID provided: " & val)
            try:
              uid = val.parseInt
            except ValueError:
              raise ValueError.newException("UID provided is not a valid number!")
          of "g", "gid":
            logger.log(lvlInfo, "Group ID provided: " & val)
            try:
              gid = val.parseInt
            except ValueError:
              raise ValueError.newException("GID provided is not a valid number!")
      of cmdEnd: assert(false)

proc run() =
  #[ Initialise configuration file. ]#
  if commandLineParams().len < 3:
    thisConfigPath.raiseIfNotExists
    if not initConf(thisConfigPath):
      raise OSError.newException("Config file could neither be found nor generated! A config file is mandatory, if not all necessary user info is provided as arguments to this app.")
  home = config.userdef.home.get("")
  name = config.userdef.name.get("")
  uid  = config.userdef.uid.get(invalidId)
  gid  = config.userdef.gid.get(invalidId)
  #[ CLI arguments overwrite configuration options, as arguments are more ad-hoc in their nature than a configuration file. ]#
  setOpts()
  if home.isEmptyOrWhitespace or name.isEmptyOrWhitespace or uid == invalidId:
    raise OSError.newException("Neither the configuration file nor the arguments provided were sufficient! You need to at least provide the custom user's home directory, name and UID!")
  if gid == invalidId: gid = uid
  let
    nameMatch = name & ":"
    passwdContent = utils.readLines(passwdPath)
    groupContent = utils.readLines(groupPath)
    passwdContentClean = passwdContent.filterNotContains(nameMatch)
    groupContentClean = groupContent.filterNotContains(nameMatch)
  passwdPath.writeFile(passwdContentClean.join(lineEnd))
  groupPath.writeFile(groupContentClean.join(lineEnd))
  let
    passwdFile = passwdPath.open(mode = fmAppend)
    groupFile = groupPath.open(mode = fmAppend)
    passwdLines = @[
      &"{name}:x:{uid}:{gid}::{home}:",
      &"{name}:!:{timestamp}:0:99999:7:::"
    ]
    groupLines = @[
      &"{name}:x:{gid}:{name}"
    ]
  passwdFile.writeLines(passwdLines)
  groupFile.writeLines(groupLines)
  passwdFile.close
  groupFile.close

when isMainModule:
  logger.log(lvlNotice, "Starting with the following configuration:\n" & pretty(%* config))
  run()