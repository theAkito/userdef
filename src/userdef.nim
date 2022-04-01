import
  userdef/[
    meta,
    configurator,
    usermanager,
    appinstructions
  ],
  std/[
    options,
    json,
    parseopt,
    strformat,
    strutils,
    logging,
    os
  ]

const invalidId = -1

let logger = newConsoleLogger(defineLogLevel(), logMsgPrefix & logMsgInter & "master" & logMsgSuffix)

var
  thisConfigPath = ""
  long = false
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

proc setOpts(params = commandLineParams()) =
  for kind, key, val in params.getopt():
    case kind
      of cmdLongOption, cmdShortOption:
        case key
          of "c", "config":
            optSetConfigPath()
          of "l", "long":
            logger.log(lvlInfo, "Long IDs enabled: " & val)
            try:
              long = val.parseBool
            except ValueError:
              long = true
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
      of cmdArgument:
        optSetConfigPath()
      of cmdEnd: assert(false)

proc run() =
  try:
    let params = commandLineParams()
    if params.contains("--help"):
      showHelp()
      quit(0)
    if params.len < 3:
      thisConfigPath.raiseIfNotExists
      if not initConf(thisConfigPath): #[ Initialise configuration file. ]#
        raise OSError.newException("Config file could neither be found nor generated! A config file is mandatory, if not all necessary user info is provided as arguments to this app.")
    home = config.userdef.home.get("")
    name = config.userdef.name.get("")
    uid  = config.userdef.uid.get(invalidId)
    gid  = config.userdef.gid.get(invalidId)
    long = config.userdef.long.get(false)
    #[ CLI arguments overwrite configuration options, as arguments are more ad-hoc in their nature than a configuration file. ]#
    params.setOpts()
    if home.isEmptyOrWhitespace or name.isEmptyOrWhitespace or uid == invalidId:
      raise OSError.newException("Neither the configuration file nor the arguments provided were sufficient! You need to at least provide the custom user's home directory, name and UID!")
    if gid == invalidId: gid = uid
    name.deleteUser()
    if long:
      logger.log(lvlDebug, "Adding user manually...")
      addUserMan(name, uid, gid, home)
    else:
      logger.log(lvlDebug, "Adding user officially...")
      addUser(name, uid, gid, home)
    logger.log(lvlDebug, "Passwd File:\n" & passwdPath.readFile)
    logger.log(lvlDebug, "Shadow File:\n" & shadowPath.readFile)
    logger.log(lvlDebug, "Group  File:\n" & groupPath.readFile)
  except:
    logger.log(lvlFatal, getCurrentExceptionMsg())
    showHelp()

when isMainModule:
  run()