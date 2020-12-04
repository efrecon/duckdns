# Duck DNS Updater

This project is both a script [`duckdns.sh`](./duckdns.sh) and
[`efrecon/duckdns`][docker], a Docker [image](#docker) to update your [Duck
DNS][duckdns] settings. It can be configured both through
[command-line](#cli-options) arguments, or through
[environment](#environment-variables) variables. The script can run once (for
`crontab` or `systemd` configuration), or perform updates at regular
[intervals](#duckdns_period). It needs at least a [domain](#duckdns_domains) and
an API [token](#duckdns_token) to perform an update. All environment variables
relevant to the configuration start with `DUCKDNS_`.

The script is written in pure POSIX shell and only depends on `wget` or `curl`.
When using `wget` it only uses options that are present in the restricted
version bundled with `busybox`. This makes this script compatible with small
embedded systems.

  [docker]: https://hub.docker.com/r/efrecon/duckdns
  [duckdns]: https://www.duckdns.org/

## Environment Variables

### `DUCKDNS_DOMAINS`

This variable should contain a comma separated list of domains to associate to
the IP address. When specifying domains, you can omit the trailing suffix
`.duckdns.org`. This variable will be overridden by the
[`--domains`](#-d-or---domains) CLI option, if present.

### `DUCKDNS_PERIOD`

This variable can contain the period at which the script should request the Duck
DNS API for an dynamic domain update. When empty, zero or negative (the
default), a single update will be made and the script will then exit. Otherwise,
this period can be either as a number of seconds, or in a human-readable form,
e.g. `1d` (one day), `2 hours`, etc. This variable will be overridden by the
[`--period`](#-p-or---period) CLI option, if present.

### `DUCKDNS_TOKEN`

This variable should contain the API token for your account at Duck DNS. This is
a UUID. This variable will be overridden by the [`--token`](#-t-or---token) CLI
option, if present.

### `DUCKDNS_IP`

This variable can contain the external IP address to associate to the domain(s).
When empty, the default, Duck DNS will automatically pick the external IP
address where this script is originating from. This variable will be overridden
by the [`--ip`](#--ip) CLI option, if present.

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

This project also comes as a Docker image published as
[`efrecon/duckdns`][docker] at the Docker hub. The image has the script as its
`ENTRYPOINT`, wrapped by `tini` to facilitate tearing down. It is based on the
latest stable Alpine version at the time of writing. When building yourself, you
can instead specify the build argument `ALPINEVER` to use another version.

The following command would run and print help for the image:

```shell
docker run -it --rm efrecon/duckdns -h
```
