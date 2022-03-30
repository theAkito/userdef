import
  meta,
  utils,
  std/[
    times,
    strformat,
    logging,
    posix
  ]

const pwPlaceholder = "x"

let
  logger = newConsoleLogger(defineLogLevel(), logMsgPrefix & logMsgInter & "usermanager" & logMsgSuffix)
  timestamp = now().toTime.toUnix div 60 div 60 div 24

## https://www.man7.org/linux/man-pages/man3/putpwent.3.html
proc putpwent(p: ptr Passwd, stream: File): int {.importc, header: "<pwd.h>", sideEffect.}
## https://linux.die.net/man/3/putgrent
proc putgrent(grp: ptr Group, fp: File): int {.importc, header: "<grp.h>", sideEffect.}

proc readPasswd(): seq[ptr Passwd] =
  var currentPwEnt: ptr Passwd
  while true:
    currentPwEnt = getpwent()
    if currentPwEnt == nil: break
    result.add currentPwEnt
  endpwent()

proc addUser(entry: ptr Passwd): bool {.discardable.} =
  # let passwdFile = passwdPath.newFileStream(mode = fmAppend)
  let passwdFile = passwdPath.open(mode = fmAppend)
  defer: passwdFile.close
  putpwent(entry, passwdFile) == 0

proc addGroup(entry: ptr Group): bool {.discardable.} =
  let grpFile = groupPath.open(mode = fmAppend)
  defer: grpFile.close
  putgrent(entry, grpFile) == 0

proc addUser*(name: string, uid, gid: int, home, shell: string): bool {.discardable.} =
  var
    realGid = gid.Gid
    passwd = Passwd(
      pw_name: name,
      pw_passwd: pwPlaceholder,
      pw_uid: uid.Uid,
      pw_gid: realGid,
      pw_gecos: "",
      pw_dir: home,
      pw_shell: shell
    )
    grpMembers = @[name].allocCStringArray
    grp = Group(
      gr_name: name,
      gr_passwd: pwPlaceholder,
      gr_gid: realGid,
      gr_mem: grpMembers
    )
  defer: grpMembers.deallocCStringArray
  addUser(passwd.addr)
  addGroup(grp.addr)

proc addUserMan*(name: string, uid, gid: int, home, shell: string) =
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
  defer: passwdFile.close
  defer: groupFile.close
  passwdFile.writeLines(passwdLines)
  groupFile.writeLines(groupLines)