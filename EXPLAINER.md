## What does dev-nginx do?

Installing and running dev-nginx will start an [nginx](https://nginx.org/en/) server instance locally on your machine.

This instance will use any `project.conf` files found locally within the directory `/nginx/servers` to generate a virtual server host to proxy local domain url requests to the correct localhost port. You can locate this directory with the command `dev-nginx locate-nginx`.

Each project config should include http directives for proxy localhost ports and necessary SSL certificates. Set these up for new projects using `dev-nginx setup-app`.

## What happens when dev-nginx is up and running locally?

1. The browser will make a request to a local development domain url, e.g. `service.local.dev-gutools.co.uk`
2. Request goes out to DNS where `*.local.dev-gutools.co.uk` is set to resolve back to `localhost` (IP address: `127.0.0.1`)
   - An alternative to using DNS is to add a new development url entry to `/etc/hosts` file resolving to 127.0.0.1.
3. Nginx server running locally receives the request
4. Nginx server iterates over its virtual hosts to match the request url to one of the `localhost:PORT` addresses it has from `project.conf` files, finilly proxying the request to the correct local project server instance.


<img src="https://user-images.githubusercontent.com/32312712/61088623-b004c980-a430-11e9-8a8b-eb78856c90d9.png" alt="diagram" width="500"/>
