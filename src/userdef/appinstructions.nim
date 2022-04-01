##[
  Displays `--help` text and manual, etc.
]##

import
  meta,
  std/[
    strformat
  ]

proc showHelp*() =
  echo()
  echo "The more reliable `adduser`, which does not let you down!"
  echo &"Visit {homepage} for detailed information."
  echo()
  echo "Usage: userdef -n=<user-name> -u=<user-id> -h=<user-home> [-g=<user-group-id>] [-l | -l=[true|false]] [-c=<path-to-config-file> | <path-to-config-file>]"
  echo()
  echo "Examples:"
  echo "  userdef --help"
  echo "  userdef -h=/var/lib/gitea/git -n=git -u=9234 -g=9234"
  echo "  userdef -h=/home/langlang -n=langlang -u=290111 -g=290111 --long"
  echo "  userdef -h=/overwrites/home/value/in/userdef.json -l=true /path/to/userdef.json"
  echo()
  echo "Options:"
  echo "  -n, --name            Name of the user to modify or add."
  echo "  -u, --uid             User ID."
  echo "  -h, --home            Path to user's home."
  echo "  -c, --config          (Optional) Provide path to configuration file."
  echo "  -g, --gid             (Optional) Group ID. If empty, then GID will be same as UID."
  echo "  -l, --long            (Optional) Whether long IDs (greater than 256000) are guaranteed to be supported."
  echo "  -v, --version         App version information."
  echo "  --help                This help text."
  echo()
  echo "Hints:"
  echo "  * If a user with the provided name already exists,"
  echo "    then it will be deleted and a new one will be created,"
  echo "    to replace the original one."
  echo()
  echo "  * Providing a configuration file works by using the `--config` option or"
  echo "    by providing the path without using any option."