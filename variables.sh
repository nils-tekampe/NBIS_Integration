# Directory the script is stored in
SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Set log directory. If it doesn’t exist yet, create it
LOGDIR="$SCRIPT_DIR/log"
if [[ ! -d "$LOGDIR" ]];
	then
	`mkdir "$LOGDIR"`
fi

# Temporary directory. If it doesn’t exist yet, create it
TMPDIR="$SCRIPT_DIR/tmp"
if [[ ! -d "$TMPDIR" ]];
	then
	`mkdir "$TMPDIR"`
fi

ERRORLOG="$LOGDIR/errors"
DEBUGLOG="$LOGDIR/debug"