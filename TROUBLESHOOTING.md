# Troubleshooting

## Hitting one hostname actually tries to serve another
`$ tail /usr/local/var/log/nginx/error.log`
shows something like this

`2020/04/03 13:37:13 [error] 51098#0: *5 kevent() reported that connect() failed (61: Connection refused) while connecting to upstream, client: 127.0.0.1, server: promo.thegulocal.com, request: "GET / HTTP/1.1", upstream: "http://[::1]:9500/", host: "mem.thegulocal.com"`

you can see the correct host mem.thegulocal.com, but the incorrect server and port number promo.thegulocal.com and 9500.

This is because if nginx can't find a matching server block for host AND protocol, it just picks the first one, which in this case is promo.  If you access with https it works fine, but be sure to define the http as well as the https in your [nginx config file](https://github.com/guardian/membership-frontend/blob/master/nginx/membership.conf) if you want the redirect to work:
```
server {
  server_name mem.thegulocal.com;

  location / {
    proxy_pass http://localhost:9100/;
      proxy_set_header Host $http_host;
  }
}
```

## Hash bucket size emerg
Seeing a message such as `nginx: [emerg] could not build server_names_hash, you should increase server_names_hash_bucket_size: 64` after starting nginx 
is a sign that an unusually long server name has been defined.

You'll want to set `server_names_hash_bucket_size` within the `http` directive in `/usr/local/etc/nginx/nginx.conf` to the next power of two. By default, 
`server_names_hash_bucket_size` is `32` so `64` or `1024` should be enough:

```
http {
  server_names_hash_bucket_size  64;
  ...
}
```

See [the docs](https://nginx.org/en/docs/http/server_names.html#optimization) for more information.
