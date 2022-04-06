import
  std/[
    os,
    strutils,
    sequtils
  ]

proc readLines*(filePath: string): seq[string] =
  filePath.readFile.splitLines

proc writeLines*(file: File, lines: seq[string]) =
  for line in lines:
    file.writeLine(line)

func filterNotContains*(lines: seq[string], name: string): seq[string] =
  lines.filterIt(not it.contains(name))

func filterNotStartsWith*(lines: seq[string], name: string): seq[string] =
  lines.filterIt(not it.startsWith(name))

proc raiseIfNotExists*(filePath: string, msg = "Path to config file provided is not a real file or cannot be found! Path to file provided: ") =
  if not filePath.fileExists:
    raise OSError.newException(msg & filePath)