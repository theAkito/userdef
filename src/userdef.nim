import
  userdef/[
    meta,
    utils,
    configurator,
    usermanager,
    appinstructions,
    argument
  ],
  userdef/model/[
    arguments
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

proc run() =
  try:
    let params = commandLineParams()
    if params.contains("--help"):
      showHelp()
      quit(0)
    if params.len < 3:
      configPath.raiseIfNotExists
      if not initConf(configPath): #[ Initialise configuration file. ]#
        raise OSError.newException("Config file could neither be found nor generated! A config file is mandatory, if not all necessary user info is provided as arguments to this app.")
    args.home = config.userdef.home.get("")
    args.name = config.userdef.name.get("")
    args.uid  = config.userdef.uid.get(invalidId)
    args.gid  = config.userdef.gid.get(invalidId)
    args.long = config.userdef.long.get(false)
    #[ CLI arguments overwrite configuration options, as arguments are more ad-hoc in their nature than a configuration file. ]#
    args.setOpts(params)
    if args.home.isEmptyOrWhitespace or args.name.isEmptyOrWhitespace or args.uid == invalidId:
      raise OSError.newException("Neither the configuration file nor the arguments provided were sufficient! You need to at least provide the custom user's home directory, name and UID!")
    if args.gid == invalidId: args.gid = args.uid
    args.name.deleteUser()
    if args.long:
      logger.log(lvlDebug, "Adding user manually...")
      addUserMan(args.name, args.uid, args.gid, args.home)
    else:
      logger.log(lvlDebug, "Adding user officially...")
      addUser(args.name, args.uid, args.gid, args.home)
    logger.log(lvlDebug, "Passwd File:\n" & passwdPath.readFile)
    logger.log(lvlDebug, "Shadow File:\n" & shadowPath.readFile)
    logger.log(lvlDebug, "Group  File:\n" & groupPath.readFile)
  except:
    logger.log(lvlFatal, getCurrentExceptionMsg())
    showHelp()

when isMainModule:
  run()