import
  userdef/[
    meta,
    utils,
    configurator,
    appinstructions,
    argument
  ],
  userdef/model/[
    arguments
  ],
  std/[
    options,
    strutils,
    logging,
    os
  ],
  pkg/[
    useradd
  ]

let logger = newConsoleLogger(defineLogLevel(), logMsgPrefix & logMsgInter & "master" & logMsgSuffix)

var
  args = Arguments(
    configPath: "",
    long: false,
    home: "",
    name: "",
    uid: invalidId,
    gid: invalidId
  )

template setOpts() = args.setOpts(params)

proc initConf() =
  if not initConf(args.configPath): #[ Initialise configuration file. ]#
    logger.log(lvlError, "Requested to read configuration file, but it could neither be found nor generated!")

proc run() =
  try:
    let params = commandLineParams()
    if params.contains("--help"):
      showHelp()
      quit(0)
    if params.contains("-v") or params.contains("--version"):
      showVersion()
      quit(0)
    if params.len < 3:
      configPath.raiseIfNotExists
      if not initConf(args.configPath): #[ Initialise configuration file. ]#
        raise OSError.newException("Config file could neither be found nor generated! A config file is mandatory, if not all necessary user info is provided as arguments to this app.")
    setOpts()
    if not args.configPath.isEmptyOrWhitespace:
      initConf()
      args.home = config.userdef.home.get("")
      args.name = config.userdef.name.get("")
      args.uid  = config.userdef.uid.get(invalidId)
      args.gid  = config.userdef.gid.get(invalidId)
      args.long = config.userdef.long.get(false)
      #[ CLI arguments overwrite configuration options, as arguments are more ad-hoc in their nature than a configuration file. ]#
      setOpts()
    if args.home.isEmptyOrWhitespace or args.name.isEmptyOrWhitespace or args.uid == invalidId:
      raise OSError.newException("Neither the configuration file nor the arguments provided were sufficient! You need to at least provide the custom user's home directory, name and UID!")
    if args.gid == invalidId: args.gid = args.uid
    if not args.name.deleteUser():
      raise OSError.newException "Failed to delete user!"
    if args.long:
      logger.log(lvlDebug, "Adding user manually...")
      if not addUserMan(args.name, args.uid, args.gid, args.home):
        raise OSError.newException "Failed to add user manually!"
    else:
      logger.log(lvlDebug, "Adding user officially...")
      if not addUser(args.name, args.uid, args.gid, args.home):
        raise OSError.newException "Failed to add user officially!"
    logger.log(lvlDebug, "Passwd File:\n" & passwdPath.readFile)
    logger.log(lvlDebug, "Shadow File:\n" & shadowPath.readFile)
    logger.log(lvlDebug, "Group  File:\n" & groupPath.readFile)
  except CatchableError:
    logger.log(lvlFatal, getCurrentExceptionMsg())
    showHelp()

when isMainModule:
  run()