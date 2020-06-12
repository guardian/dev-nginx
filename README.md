# dev-nginx

Tools to configure a local development nginx setup to proxy our applications and services with SSL using [mkcert](https://github.com/FiloSottile/mkcert).

This typically allows accessing servers via
`service.local.dev-gutools.co.uk`, rather than a `localhost:PORT` URL,
which among other things makes it possible to share cookies for the [pan-domain authentication](https://github.com/guardian/pan-domain-authentication).

### What does dev-nginx do?

Installing and running dev-nginx will start an [nginx](https://nginx.org/en/) server instance locally on your machine.

This instance will use any `*.conf` files found locally within the directory `/nginx/servers` to generate a virtual server host to proxy requests to localhost. You can locate this directory with the command `dev-nginx locate`.

Each project config should include http directives for proxy localhost ports and necessary SSL certificates. This is quite repetitive, so `dev-nginx` abstracts it away with the `setup-app` and `setup-cert` commands.

### What happens when dev-nginx is up and running locally?

1. The browser will make a request to a local development domain url, e.g. `service.local.dev-gutools.co.uk`
2. Request goes out to DNS where `*.local.dev-gutools.co.uk` is set to resolve back to `localhost` (IP address: `127.0.0.1`)
   - An alternative to using DNS is to add a new development url entry to `/etc/hosts` file resolving to 127.0.0.1. This can be done with `dev-nginx add-to-hosts-file <DOMAIN>`.
3. Nginx server running locally receives the request
4. Nginx server iterates over its virtual hosts, if it finds a `server_name` that matches the request, it will then proxy the request to the correct local project server instance.

<img src="https://user-images.githubusercontent.com/32312712/61088623-b004c980-a430-11e9-8a8b-eb78856c90d9.png" alt="diagram" width="500"/>

## Installation

### Via Homebrew

```bash
brew tap guardian/homebrew-devtools
brew install guardian/devtools/dev-nginx

# update
brew upgrade dev-nginx
```

### Manually

As listed in the [Brewfile](./Brewfile), `dev-nginx` requires:

- [`nginx`](https://docs.nginx.com/nginx/admin-guide/installing-nginx/installing-nginx-open-source/)
- [`mkcert`](https://github.com/FiloSottile/mkcert).

Once you have installed these dependencies, you can:

- Download the [latest release](https://github.com/guardian/dev-nginx/releases/latest)
- Extract it
- Add the `bin` directory to your PATH.

For example:

```bash
wget -q https://github.com/guardian/dev-nginx/releases/latest/download/dev-nginx.tar.gz
mkdir -p dev-nginx && tar -xzf dev-nginx.tar.gz -C dev-nginx
export PATH="$PATH:$PWD/dev-nginx/bin"
```

## Usage

`dev-nginx` has a few commands available. Find them by passing no arguments:

```console
$ dev-nginx

dev-nginx COMMAND <OPTIONS>
Available commands:
- add-to-hosts-file
- link-config
- locate
- restart
- setup-app
- setup-cert
- start
```

### Commands

#### `add-to-hosts-file`

```bash
dev-nginx add-to-hosts-file
```

If it does not already exist, adds an entry to `/etc/hosts` that resolves to `127.0.0.1`.

#### `link-config`

```bash
dev-nginx link-config /path/to/site.conf
```

Symlink an existing file into nginx configuration. You'll need to restart nginx to activate it (`dev-nginx restart`).

#### `locate`

```bash
dev-nginx locate
```

Locates the directory nginx is installed.

#### `start`
```bash
dev-nginx start
```

Starts nginx. Will fail if currently running. Add `-i` to ignore if nginx is currently running.

#### `restart`

```bash
dev-nginx restart
```

Stops, if running, and starts nginx.

#### `setup-cert`

```bash
dev-nginx setup-cert demo-frontend.foobar.co.uk
```

Uses `mkcert` to issue a certificate for a domain, writing it to `~/.gu/mkcert` and symlinking it into the directory nginx is installed.

#### `setup-app`

```bash
dev-nginx setup-app /path/to/nginx-mapping.yml
```

Generates config for nginx proxy site(s) from a config file, issues the certificate(s) and restarts nginx.

##### Config format

Your application's configuration is provided as a YAML file in the following format.

**Example:**

```yaml
name: demo
domain-root: foobar.co.uk
mappings:
  - port: 9001
    prefix: demo-frontend
  - port: 8800
    prefix: demo-api
```

In general, the format is as follows:

```yaml
name: <name of the project, used as its filename>
mappings: <list of server mappings>
ssl: <optional, defaults to `true` (you are unlikely to need to change this)>
domain-root: <optional, defaults to `local.dev-gutools.co.uk`>
```

Each mapping supports the following fields:

###### prefix

**required**

This is the domain prefix used for the service and will be prepended to the domain.
The default domain is `local.dev-gutools.co.uk`
but this can be overridden using the `domain-root` key at the top level (to apply to all mappings) or in a mapping (to set the domain root for just that mapping).

###### port

**required**

This sets the port that will be proxied - i.e. the upstream backend service. These are commonly in the 9XXXs or 8XXXs.

###### websocket

This optionally sets the path for a websocket. If present, nginx will be configured to serve websocket traffic at that location.

###### client_max_body_size

Optionally instructs nginx to set a max body size on incoming requests.

###### domain-root

The domain under which the service should run, which defaults to `local.dev-gutools.co.uk`.
This can also be overriden for all mappings by specifying a `domain-root` key at the top level.

##### Hosts file

You'll need to ensure your hosts file has entries for your new domains, so that they resolve:

```
127.0.0.1   demo-frontend.foobar.co.uk
127.0.0.1   demo-api.foobar.co.uk
```
