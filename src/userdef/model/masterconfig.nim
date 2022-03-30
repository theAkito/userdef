from options import Option

type
  UserDef       * = object
    home        * : Option[string] ## Home directory of the OS user.
    name        * : Option[string] ## Name of the OS user.
    uid         * : Option[int] ## User  ID of the OS user.
    gid         * : Option[int] ## Group ID of the OS user.

  MasterConfig  * = object
    version     * : string  ## Version of this app and its configuration API.
    userdef     * : UserDef ## User Definition.
    debug       * : bool    ## Enable Debug mode.