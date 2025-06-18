# Troubleshooting

## Hitting one hostname actually tries to serve another
This can happen if you don't use the standard [setup-app command](README.md#setup-app)

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

## OAuth Cookies Not Persisting After Callback

### Symptoms:

- After completing the /oauth/callback flow, the expected cookies (GU_ACCESS_TOKEN, GU_ID_TOKEN) are not persisted in the browser.
- The browser receives a 502 Bad Gateway response from Nginx during or after the callback step.
- No visible application error occurs client-side, making the issue hard to trace.

### Root Cause:
The total size of the cookies being set (particularly access_token and id_token) exceeded Nginx’s default buffer limits. When the combined size of all Set-Cookie headers goes beyond ~8KB, Nginx silently truncates or drops the headers, resulting in failed cookie persistence and a 502 response.

### Why this only affected some developers:

- Token sizes vary based on user profile complexity, scopes, or IDP configuration.
- Some tokens remained under the limit, while others exceeded it — depending on the Okta response.
- Developers with longer tokens encountered the silent header truncation and 502 error.
- At the time of writing this entry, I was using a Intel Macbook Pro.

### Fix: Increase Nginx Header and Cookie Size Limits

To support larger headers and cookies, increase the buffer sizes in your nginx.conf. Add the following inside the http block:

```
http {
    ...
    proxy_buffer_size 16k;
    proxy_buffers 8 16k;
    proxy_busy_buffers_size 32k;
    large_client_header_buffers 4 16k;
    ...
}
```

Then restart Nginx:

```
brew services restart nginx
```
or
```
sudo nginx -s reload
```
