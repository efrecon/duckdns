#!/usr/bin/env sh

set -efu

VERBOSE=1

if [ -t 1 ]; then
    INTERACTIVE=1
else
    INTERACTIVE=0
fi

# Domains to associate to the IP
DUCKDNS_DOMAINS=${DUCKDNS_DOMAINS:-}

# When empty, this will default to the external IP from where this scripts
# originate from.
DUCKDNS_IP=${DUCKDNS_IP:-}

# Token to authorise with at duckdns
DUCKDNS_TOKEN=${DUCKDNS_TOKEN:-}

# URL to DuckDNS update API service
DUCKDNS_URL=${DUCKDNS_URL:-"https://www.duckdns.org/update"}

# Period at which to update, empty, negative or zero for once, the default
DUCKDNS_PERIOD=${DUCKDNS_PERIOD:-}

DUCKDNS_TIMEOUT=${DUCKDNS_TIMEOUT:-30}

# Dynamic vars
cmdname=$(basename "$(readlink -f "$0")")
# shellcheck disable=SC2034
appname=${cmdname%.*};  # Used in logging

# Print usage on stderr and exit
usage() {
  exitcode="$1"
  cat << USAGE >&2
Description:
  $cmdname will update (once or regularily) the IP address associated to one
  or several domains at DuckDNS.org

Usage:
  $cmdname [-option arg --long-option(=)arg]
  where all dash-led options are as follows (long options can be followed by
  an equal sign):
    -t | --token       API token at DuckDNS
    -d | --domains     Comma separated list of domains to update, you can leave
                       out the .duckdns.org part
    -p | --period      Period at which to update, negative or zero for once only
    --ip               External IP address to associate the domains to. Leave
                       blank (the default) to let Duck DNS detect
    --url              Full URL to duckdns API updater entry
    --silent | --quiet Be as silent as possible
    -h | --help        Print this help and quit

Details:
  The period is expressed in seconds, but the implentation understands human-
  readable expressions such as 1d (1 day), 2h (2 hours), etc.

  You can also control the behaviour of this script through environment
  variables. See https://github.com/efrecon/duckdns for more information.

USAGE
  exit "$exitcode"
}


# Parse options
while [ $# -gt 0 ]; do
    case "$1" in
        -d | --domains | --domain)
            DUCKDNS_DOMAINS=$2; shift 2;;
        --domains=* | --domain=*)
            # shellcheck disable=SC2034
            DUCKDNS_DOMAINS="${1#*=}"; shift 1;;

        -p | --period)
            DUCKDNS_PERIOD=$2; shift 2;;
        --period=*)
            # shellcheck disable=SC2034
            DUCKDNS_PERIOD="${1#*=}"; shift 1;;

        -t | --token)
            DUCKDNS_TOKEN=$2; shift 2;;
        --token=*)
            # shellcheck disable=SC2034
            DUCKDNS_TOKEN="${1#*=}"; shift 1;;

        --ip)
            DUCKDNS_IP=$2; shift 2;;
        --ip=*)
            # shellcheck disable=SC2034
            DUCKDNS_IP="${1#*=}"; shift 1;;

        --silent | --quiet)
            # shellcheck disable=SC2034
            VERBOSE=0; shift;;

        -h | --help)
            usage 0;;
        --)
            shift; break;;
        -*)
            echo "Unknown option: $1 !" >&2 ; usage 1;;
        *)
            break;;
    esac
done


# Colourisation support for logging and output.
_colour() {
  if [ "$INTERACTIVE" = "1" ]; then
    printf '\033[1;31;'${1}'m%b\033[0m' "$2"
  else
    printf -- "%b" "$2"
  fi
}
green() { _colour "32" "$1"; }
red() { _colour "40" "$1"; }
yellow() { _colour "33" "$1"; }
blue() { _colour "34" "$1"; }

# Conditional logging
log() {
  if [ "$VERBOSE" = "1" ]; then
    echo "[$(blue "${2:-$appname}")] [$(yellow info)] [$(date +'%Y%m%d-%H%M%S')] $1" >&2
  fi
}

warn() {
  echo "[$(blue "${2:-$appname}")] [$(red WARN)] [$(date +'%Y%m%d-%H%M%S')] $1" >&2
}

abort() {
  warn "$1"
  exit 1
}

# Return the approx. number of seconds for the human-readable period passed as a
# parameter
howlong() {
    if echo "$1"|grep -Eqo '^[0-9]+[[:space:]]*[yY]'; then
        len=$(echo "$1"  | sed -En 's/([0-9]+)[[:space:]]*[yY].*/\1/p')
        expr "$len" \* 31536000
        return
    fi
    if echo "$1"|grep -Eqo '^[0-9]+[[:space:]]*[Mm][Oo]'; then
        len=$(echo "$1"  | sed -En 's/([0-9]+)[[:space:]]*[Mm][Oo].*/\1/p')
        expr "$len" \* 2592000
        return
    fi
    if echo "$1"|grep -Eqo '^[0-9]+[[:space:]]*m'; then
        len=$(echo "$1"  | sed -En 's/([0-9]+)[[:space:]]*m.*/\1/p')
        expr "$len" \* 2592000
        return
    fi
    if echo "$1"|grep -Eqo '^[0-9]+[[:space:]]*[Ww]'; then
        len=$(echo "$1"  | sed -En 's/([0-9]+)[[:space:]]*[Ww].*/\1/p')
        expr "$len" \* 604800
        return
    fi
    if echo "$1"|grep -Eqo '^[0-9]+[[:space:]]*[Dd]'; then
        len=$(echo "$1"  | sed -En 's/([0-9]+)[[:space:]]*[Dd].*/\1/p')
        expr "$len" \* 86400
        return
    fi
    if echo "$1"|grep -Eqo '^[0-9]+[[:space:]]*[Hh]'; then
        len=$(echo "$1"  | sed -En 's/([0-9]+)[[:space:]]*[Hh].*/\1/p')
        expr "$len" \* 3600
        return
    fi
    if echo "$1"|grep -Eqo '^[0-9]+[[:space:]]*[Mm][Ii]'; then
        len=$(echo "$1"  | sed -En 's/([0-9]+)[[:space:]]*[Mm][Ii].*/\1/p')
        expr "$len" \* 60
        return
    fi
    if echo "$1"|grep -Eqo '^[0-9]+[[:space:]]*M'; then
        len=$(echo "$1"  | sed -En 's/([0-9]+)[[:space:]]*M.*/\1/p')
        expr "$len" \* 60
        return
    fi
    if echo "$1"|grep -Eqo '^[0-9]+[[:space:]]*[Ss]'; then
        len=$(echo "$1"  | sed -En 's/([0-9]+)[[:space:]]*[Ss].*/\1/p')
        echo "$len"
        return
    fi
    if echo "$1"|grep -Eqo '^[0-9]+'; then
        echo "$1"
        return
    fi
}

update() {
  _url="${DUCKDNS_URL}?domains=${DUCKDNS_DOMAINS}&token=${DUCKDNS_TOKEN}&ip=${DUCKDNS_IP}"
  res=$($download "$_url")
  if [ "$res" = "OK" ]; then
    log "Successfully updated IP for domain(s): $DUCKDNS_DOMAINS"
  else
    warn "Could not update IP for domain(s): $DUCKDNS_DOMAINS"
  fi
}

[ -z "$DUCKDNS_DOMAINS" ] && abort "You must specify at least a domain, run with -h for help"
[ -z "$DUCKDNS_TOKEN" ] && abort "You must specify an API token, run with -h for help"

# Decide how to download silently
download=
if command -v curl >/dev/null; then
  log "Using curl for updates"
  # shellcheck disable=SC2037
  download="curl -sSL -m $DUCKDNS_TIMEOUT"
elif command -v wget >/dev/null; then
  log "Using wget for updates"
  # shellcheck disable=SC2037
  download="wget -q -O- -T $DUCKDNS_TIMEOUT"
else
  warn "Can neither find curl, nor wget!"
fi

period=0
if [ -n "$DUCKDNS_PERIOD" ]; then
  period=$(howlong "$DUCKDNS_PERIOD")
fi

if [ "$period" -gt 0 ]; then
  log "Will update domain(s) $DUCKDNS_DOMAINS every $period s."
  while true; do
    update
    sleep "$period"
  done
else
  update
fi