# Troubleshooting

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