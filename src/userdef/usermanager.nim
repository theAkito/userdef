import
  meta,
  utils,
  std/[
    times,
    strformat,
    strutils,
    logging,
    posix
  ]

const pwPlaceholder = "x"

let
  logger = newConsoleLogger(defineLogLevel(), logMsgPrefix & logMsgInter & "usermanager" & logMsgSuffix)
  timestamp = now().toTime.toUnix div 60 div 60 div 24 ## https://stackoverflow.com/questions/1094291/get-current-date-in-epoch-from-unix-shell-script/1094354#1094354

proc putpwent(p: ptr Passwd, stream: File): int {.importc, header: "<pwd.h>", sideEffect.} ## https://linux.die.net/man/3/putpwent
proc putgrent(grp: ptr Group, fp: File): int {.importc, header: "<grp.h>", sideEffect.} ## https://linux.die.net/man/3/putgrent

proc readPasswd(): seq[ptr Passwd] =
  ## Reads all password entries from `/etc/passwd`.
  var currentPwEnt: ptr Passwd
  while true:
    currentPwEnt = getpwent()
    if currentPwEnt == nil: break
    result.add currentPwEnt
  endpwent()

proc addUser(entry: ptr Passwd): bool =
  let passwdFile = passwdPath.open(mode = fmAppend)
  defer: passwdFile.close
  putpwent(entry, passwdFile) == 0

proc addGroup(entry: ptr Group): bool =
  let grpFile = groupPath.open(mode = fmAppend)
  defer: grpFile.close
  putgrent(entry, grpFile) == 0

proc addUser*(name: string, uid, gid: int, home: string, shell = "", pw = pwPlaceholder): bool {.discardable.} =
  ## Adds an OS user the official C API way.
  var
    realGid = gid.Gid
    passwd = Passwd(
      pw_name: name,
      pw_passwd: pw, # https://serverfault.com/questions/330069/how-to-create-an-sha-512-hashed-password-for-shadow
      pw_uid: uid.Uid,
      pw_gid: realGid,
      pw_gecos: "", # https://www.redhat.com/sysadmin/linux-gecos-demystified
      pw_dir: home,
      pw_shell: shell
    )
    grpMembers = @[name].allocCStringArray
    grp = Group(
      gr_name: name,
      gr_passwd: pw,
      gr_gid: realGid,
      gr_mem: grpMembers
    )
  defer: grpMembers.deallocCStringArray
  addUser(passwd.addr) and addGroup(grp.addr)

proc addUserMan*(name: string, uid, gid: int, home: string, shell = "", pw = pwPlaceholder) =
  ## Adds an OS user the manual way, by appending a user entry to `/etc/passwd`, `/etc/shadow` and
  ## a corresponding group entry to `/etc/group`.
  ##
  ## This manual method guarantees, that IDs consisting of numbers larger than
  ## 256000 are successfully applied, when creating a user.
  ## In Alpine's BusyBox version of `adduser` this is a general restriction,
  ## which can (relatively) safely by avoided by adding an `/etc/passwd` entry,
  ## manually, by editing the file directly.
  ##
  ## For more information on this topic visit the following references.
  ## https://stackoverflow.com/a/42133612/1483861
  ## https://github.com/docksal/unison/issues/5
  ## https://github.com/docksal/unison/pull/1/files
  ## https://github.com/docksal/unison/pull/7
  ## https://github.com/docksal/unison/pull/1#issuecomment-471114725
  let
    passwdFile = passwdPath.open(mode = fmAppend)
    shadowFile = shadowPath.open(mode = fmAppend)
    groupFile = groupPath.open(mode = fmAppend)
    passwdLines = @[
      &"{name}:{pw}:{uid}:{gid}::{home}:"
    ]
    shadowLines = @[
      &"{name}:!:{timestamp}:0:99999:7:::"
    ]
    groupLines = @[
      &"{name}:{pw}:{gid}:{name}"
    ]
  defer: passwdFile.close
  defer: shadowFile.close
  defer: groupFile.close
  passwdFile.writeLines(passwdLines)
  shadowFile.writeLines(shadowLines)
  groupFile.writeLines(groupLines)

proc deleteUser*(name: string) =
  ## Deletes a user by manually deleting its entry from `/etc/passwd`, `/etc/shadow` and
  ## a corresponding group entry from `/etc/group`.
  let
    nameMatch = name & ":"
    passwdContent = utils.readLines(passwdPath)
    shadowContent = utils.readLines(shadowPath)
    groupContent = utils.readLines(groupPath)
    passwdContentClean = passwdContent.filterNotStartsWith(nameMatch)
    shadowContentClean = shadowContent.filterNotStartsWith(nameMatch)
    groupContentClean = groupContent.filterNotStartsWith(nameMatch)
  passwdPath.writeFile(passwdContentClean.join(lineEnd))
  shadowPath.writeFile(shadowContentClean.join(lineEnd))
  groupPath.writeFile(groupContentClean.join(lineEnd))