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
To install the nginx config for an application that has an `nginx-mapping.yml` file:

```bash
./setup-app.rb path/to/nginx-mapping.yml
```

Note that you will need to run this command again if the mapping file changes.
