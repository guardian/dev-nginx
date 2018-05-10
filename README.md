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

## Install SSL certificates
To install the SSL certificate files:

```
$ ./setup-certs.sh
```

NB: If you've never ran nginx before performing the above step the script might issue 

```
nginx: [error] open() "/usr/local/var/run/nginx.pid" failed (2: No such file or directory)
```

in which case it should be enough to just rerun it. 

## Trust the certificates
Add the chained certificates to your [Keychain](https://support.apple.com/kb/PH18677?locale=en_US). and trust it for SSL connections.

The chained certificates are:
- [star.local.dev-gutools.co.uk.chained.crt](ssl/star.local.dev-gutools.co.uk.chained.crt)
- [star.media.local.dev-gutools.co.uk.chained.crt](ssl/star.media.local.dev-gutools.co.uk.chained.crt)

### Firefox
Firefox uses its own certificate repository - [guide](http://www.cyberciti.biz/faq/firefox-adding-trusted-ca/).
NB: This guide is slightly out of date. The "Encryption" pane in the "Advanced" menu item is now called "Certificates". 
Then, after importing the certificate, you might have to tick all options of the "trust settings" section.

## Install config for an application
To install the nginx config for an application that has an `nginx-mapping.yml` file:

```
$ sudo ./setup-app.rb path/to/nginx-mapping.yml
```

Note that you will need to run this command again if the mapping file changes.

## Certificate chains
Many internal certificates require the intermediate certificate to be available
in order to validate the trust in the host certificate.

This is typically the GNM-DC1-intermediate certificate.

The best way of checking is to inspect the certificates using `openssl`:

```
> openssl x509 -in GNM-DC1-intermediate.crt -text
... <snip> ...
            X509v3 Subject Key Identifier:
                4F:DD:7D:96:EE:FD:1B:AD:FE:D7:44:8C:16:06:E3:59:6B:74:5C:AD
... <snip> ...
            X509v3 Authority Key Identifier:
                keyid:E0:6B:11:7E:54:6D:7E:3E:E7:AB:27:EF:2E:3A:92:5D:AE:81:C1:7D
... <snip> ...
```

In the output you will find the ID of the key for this certificate (the Subject
  Key Identifier) and the ID of the key that signed this certificate (the Authority
  Key Identifier). The AKI will either be the subject key of the root certificate
  or of an intermediate cert.

In the example above we are inspecting the intermediate certificate. The AKI is
  the ID of the root certificate. Any certificate signed by this intermediate
  certificate will have an AKI that matches the SKI of this key.

Run the same command against the root and intermediate certificates and you can
  establish what the chain is.

A certificate chain file for nginx is the server certificate concatenated with
  each intermediate certificate (except for the root certificate). In most cases
  it will just be one certificate. For example the star.local.dev-gutools.co.uk
  certificate chain was created using the following command:

```
cat star.local.dev-gutools.co.uk.crt GNM-DC1-intermediate.crt > star.local.dev-gutools.co.uk.chained.crt
```

If a certificate is signed directly by the root CA then there is no need to do
this, you can just provide the server certificate on its own.
