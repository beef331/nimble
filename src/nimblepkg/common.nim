# Copyright (C) Dominik Picheta. All rights reserved.
# BSD License. Look at license.txt for more info.
#
# Various miscellaneous common types reside here, to avoid problems with
# recursive imports

import sets, tables, terminal
import version

type
  BuildFailed* = object of NimbleError

  PackageInfo* = object
    myPath*: string ## The path of this .nimble file
    isNimScript*: bool ## Determines if this pkg info was read from a nims file
    isMinimal*: bool
    isInstalled*: bool ## Determines if the pkg this info belongs to is installed
    isLinked*: bool ## Determines if the pkg this info belongs to has been linked via `develop`
    nimbleTasks*: HashSet[string] ## All tasks defined in the Nimble file
    postHooks*: HashSet[string] ## Useful to know so that Nimble doesn't execHook unnecessarily
    preHooks*: HashSet[string]
    name*: string
    ## The version specified in the .nimble file.Assuming info is non-minimal,
    ## it will always be a non-special version such as '0.1.4'
    version*: string
    specialVersion*: string ## Either `myVersion` or a special version such as #head.
    author*: string
    description*: string
    license*: string
    skipDirs*: seq[string]
    skipFiles*: seq[string]
    skipExt*: seq[string]
    installDirs*: seq[string]
    installFiles*: seq[string]
    installExt*: seq[string]
    requires*: seq[PkgTuple]
    bin*: Table[string, string]
    binDir*: string
    srcDir*: string
    backend*: string
    foreignDeps*: seq[string]
    checksum*: string

  ## Same as quit(QuitSuccess), but allows cleanup.
  NimbleQuit* = ref object of CatchableError

  ProcessOutput* = tuple[output: string, exitCode: int]

  NimbleDataJsonKeys* = enum
    ndjkVersion = "version"
    ndjkRevDep = "reverseDeps"
    ndjkRevDepName = "name"
    ndjkRevDepVersion = "version"
    ndjkRevDepChecksum = "checksum"

const
  nimbleVersion* = "0.13.1"
  nimbleDataFile* = (name: "nimbledata.json", version: "0.1.0")

proc raiseNimbleError*(msg: string, hint = "") =
  var exc = newException(NimbleError, msg)
  exc.hint = hint
  raise exc

proc getOutputInfo*(err: ref NimbleError): (string, string) =
  var error = ""
  var hint = ""
  error = err.msg
  when not defined(release):
    let stackTrace = getStackTrace(err)
    error = stackTrace & "\n\n" & error
  if not err.isNil:
    hint = err.hint

  return (error, hint)

proc reportUnitTestSuccess*() =
  if programResult == QuitSuccess:
    stdout.styledWrite(fgGreen, "All tests passed.")

when not declared(initHashSet):
  import sets

  template initHashSet*[A](initialSize = 64): HashSet[A] =
    initSet[A](initialSize)

when not declared(toHashSet):
  import sets

  template toHashSet*[A](keys: openArray[A]): HashSet[A] =
    toSet(keys)
