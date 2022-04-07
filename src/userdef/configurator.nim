import
  meta,
  std/[
    options,
    json,
    os,
    logging,
    strutils
  ],
  model/[
    masterconfig
  ]

let
  logger = newConsoleLogger(defineLogLevel(), logMsgPrefix & logMsgInter & "configurator" & logMsgSuffix)
var
  init = false
  userdef = UserDef(
    home: some(""),
    name: some(""),
    uid: some(-1),
    gid: some(-1),
    long: some(false)
  )
  config* = MasterConfig(
    version: appVersion,
    userdef: userdef,
    debug: meta.debug
  )

func pretty(node: JsonNode): string = node.pretty(configIndentation)

func genPathFull(path, name: string): string =
  if path != "": path.normalizePathEnd() & '/' & name else: name

proc getConfig*(): MasterConfig = config

proc genDefaultConfig(path = configPath, name = configName): JsonNode =
  let
    pathFull = path.genPathFull(name)
    conf = %* config
  pathFull.writeFile(conf.pretty())
  conf

proc initConf*(path = configPath, name = configName): bool =
  if init:
    logger.log(lvlDebug, "Config already initialised!")
    return true
  let
    pathFull = path.genPathFull(name)
    configAlreadyExists = pathFull.fileExists
  if configAlreadyExists:
    logger.log(lvlDebug, "Config already exists! Not generating new one.")
    config = pathFull.parseFile().to(MasterConfig)
    init = true
    return true
  try:
    genDefaultConfig(path, name)
  except:
    return false
  init = true
  true