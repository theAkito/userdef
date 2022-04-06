#[
  App argument parsing.
]#

import
  meta,
  utils,
  model/[
    arguments
  ],
  std/[
    logging,
    os,
    strformat,
    strutils,
    parseopt
  ]

let logger = newConsoleLogger(defineLogLevel(), logMsgPrefix & logMsgInter & "arguments" & logMsgSuffix)

template optSetConfigPath() =
  logger.log(lvlInfo, "Config path provided: " & val)
  args.configPath = val
  args.configPath.raiseIfNotExists

proc setOpts*(args: var Arguments, params = commandLineParams()) =
  var opt = initOptParser(
    params,
    shortNoVal = {
      'l',
      'v'
    },
    longNoVal = @[
      "long",
      "version"
    ]
  )
  for kind, key, val in opt.getopt():
    case kind
      of cmdLongOption, cmdShortOption:
        case key
          of "c", "config":
            optSetConfigPath()
          of "l", "long":
            logger.log(lvlInfo, "Long IDs enabled: " & val)
            try:
              args.long = val.parseBool
            except ValueError:
              args.long = true
          of "h", "home":
            logger.log(lvlInfo, "User home provided: " & val)
            args.home = val
          of "n", "name":
            logger.log(lvlInfo, "User Name provided: " & val)
            args.name = val
          of "u", "uid":
            logger.log(lvlInfo, "User ID provided: " & val)
            try:
              args.uid = val.parseInt
            except ValueError:
              raise ValueError.newException("UID provided is not a valid number!")
          of "g", "gid":
            logger.log(lvlInfo, "Group ID provided: " & val)
            try:
              args.gid = val.parseInt
            except ValueError:
              raise ValueError.newException("GID provided is not a valid number!")
      of cmdArgument:
        optSetConfigPath()
      of cmdEnd: assert(false)