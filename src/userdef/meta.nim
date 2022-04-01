from logging import Level

const
  debug             * {.booldefine.} = false
  lineEnd           * {.strdefine.}  = "\n"
  defaultDateFormat * {.strdefine.}  = "yyyy-MM-dd'T'HH:mm:ss'.'fffffffff'Z'"
  logMsgPrefix      * {.strdefine.}  = "[$levelname]:[$datetime]"
  logMsgInter       * {.strdefine.}  = " ~ "
  logMsgSuffix      * {.strdefine.}  = " -> "
  appVersion        * {.strdefine.}  = "0.1.0"
  configName        * {.strdefine.}  = "userdef.json"
  configPath        * {.strdefine.}  = ""
  configIndentation * {.intdefine.}  = 2
  passwdPath        * {.strdefine.}  = "/etc/passwd"
  shadowPath        * {.strdefine.}  = "/etc/shadow"
  groupPath         * {.strdefine.}  = "/etc/group"
  sourcepage        * {.strdefine.}  = "https://github.com/theAkito/userdef"
  homepage          * {.strdefine.}  = sourcepage
  wikipage          * {.strdefine.}  = sourcepage


func defineLogLevel*(): Level =
  if debug: lvlDebug else: lvlInfo