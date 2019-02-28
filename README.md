# nginx dev setup

Tools to configure a local development nginx setup to proxy our applications and services.

This typically allows accessing servers via
`service.local.dev-gutools.co.uk`, rather than a `localhost:PORT` URL,
which among other things makes it possible to share cookies for the [pan-domain authentication](https://github.com/guardian/pan-domain-authentication).

## Install ngnix
To install `nginx` on OSX, make sure you have `homebrew` and then run 

```
brew install nginx
```

## Install mkcert
We use `mkcert` to create certificates, make sure you have `homebrew` and then run:  

```
brew install mkcert nss
```

## Install config for an application
To install the nginx config for an application that has an `nginx-mapping.yml` file:

```
$ sudo ./setup-app.rb path/to/nginx-mapping.yml
```

Note that you will need to run this command again if the mapping file changes.
