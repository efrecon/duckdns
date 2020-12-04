# Duck DNS Updater

This project is both a script and a Docker image to update your Duck DNS
settings. It can be configured both through command-line arguments, or through
environment variables. The script can run once (for `crontab` or `systemd`
configuration), or perform updates at regular intervals. It needs at least a
domain and an API token to perform an update. All environment variables relevant
to the configuration start with `DUCKDNS_`.

The script is written in pure POSIX shell and only depends on `wget` or `curl`.
When using `wget` it uses only options that are present in the restricted
version bundled with `busybox`. This makes this script compatible with small
embedded systems.

## Environment Variables

### `DUCKDNS_DOMAINS`

This variable should contain a comma separated list of domains to associate to
the IP address. When specifying domains, you can omit the trailing suffix
`.duckdns.org`.

### `DUCKDNS_PERIOD`

This variable can contain the period at which the script should request the Duck
DNS API for an dynamic domain update. When empty, zero or negative (the
default), a single update will be made and the script will then exit. Otherwise,
this period can be either as a number of seconds, or in a human-readable form,
e.g. `1d` (one day), `2 hours`, etc.

### `DUCKDNS_TOKEN`

This variable should contain the API token for your account at Duck DNS. This is
a UUID.

### `DUCKDNS_IP`

This variable can contain the external IP address to associate to the domain(s).
When empty, the default, Duck DNS will automatically pick the external IP
address where this script is originating from.

### `DUCKDNS_URL`

This variable can contain the root URL for the Duck DNS API updates. This
defaults to `https://www.duckdns.org/update` and there are little reasons to
change this.

### `DUCKDNS_TIMEOUT`

This variable can contain the timeout for the network operations to the Duck DNS
servers. This should be an integer and defaults to `30`.

### `VERBOSE`

This variable can be set to `0` to only print warnings.

## CLI Options

CLI options always have precedence over environment variables. Most variables
have an equivalent among the CLI options. Important options have a short and a
long version. Double-dashed options can be separated from their value with a
space or an equal sign.

### `-d` or `--domains`

This is the same as the [`DUCKDNS_DOMAINS`](#duckdns_domains) environment
variable.

### `-p` or `--period`

This is the same as the [`DUCKDNS_PERIOD`](#duckdns_period) environment
variable.

### `-t` or `--token`

This is the same as the [`DUCKDNS_TOKEN`](#duckdns_token) environment
variable.

### `--ip`

This is the same as the [`DUCKDNS_IP`](#duckdns_ip) environment variable.

### `--silent` or `--quiet`

This is a flag that will turn the [`VERBOSE`](#verbose) environment variable to
`0`, thus only printing on warnings and errors.

## Docker

