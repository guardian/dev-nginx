# nginx dev setup

Tools to configure a local development nginx setup to proxy our applications and services with SSL using [mkcert](https://github.com/FiloSottile/mkcert).

This typically allows accessing servers via
`service.local.dev-gutools.co.uk`, rather than a `localhost:PORT` URL,
which among other things makes it possible to share cookies for the [pan-domain authentication](https://github.com/guardian/pan-domain-authentication).

## Install dependencies
Dependencies are listed in the [Brewfile](./Brewfile). Install them using:

```bash
brew bundle
```

## Install config for an application

To install the nginx config for an application that has an `nginx-mapping.yml` file (see below):

```bash
./setup-app.rb path/to/nginx-mapping.yml
```

Note that you will need to run this command again if the mapping file changes.

### Config format

Your application's configuration is provided as a YAML file in the following format.

**Example:**

```yaml
name: demo
mappings:
- port: 9001
  prefix: demo-frontend
- port: 8800
  prefix: demo-api
```

In general, the format is as follows:

```yaml
name: <name of the project, used as its filename>
mappings:
  <list of server mappings>
ssl: <optional, defaults to `true` (you are unlikely to need to change this)>
domain-root: <optional, defaults to `local.dev-gutools.co.uk`>
```

Each mapping can supports the following fields:

#### prefix

**required**

This is the domain prefix used for the service and will be prepended to the domain. The default domain is `local.dev-gutools.co.uk` but this can be overridden via configuration or

#### port

Defaults to 443 for secure services, and 80 otherwise. This is typically required.

This sets the port used for the backend service. These are commonly in the 9XXXs or 8XXXs.

#### websocket

This optionally sets the path for a websocket. If present, nginx will be configured to serve websocket traffic at that location.

#### client_max_body_size

Optionally instructs nginx to set a max body size on incoming requests.
