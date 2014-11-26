#!/usr/bin/env ruby

require 'yaml'
require 'fileutils'

if ARGV.size != 1
    puts "usage: setup-app.rb <config.yml>"
    exit(1)
end

DEFAULT_DOMAIN_ROOT = "local.dev-gutools.co.uk"
NGINX_DIR = `./locate-nginx.sh`.chomp

config_file = ARGV[0]

config = YAML.load_file(config_file)
name = config['name']
ssl = config.key?('ssl') ? config['ssl'] : true
port = ssl ? 443 : 80
global_domain_root = config['domain-root'] || DEFAULT_DOMAIN_ROOT
dest_dir = File.join(NGINX_DIR, "sites-enabled")
FileUtils.mkdir_p(dest_dir)

dest = File.join(dest_dir, "#{name}.conf")

file = File.open(dest, 'w') do |file|

    config['mappings'].each do |mapping|

        domain_root = mapping['domain-root'] || global_domain_root
        path = mapping['path'] || ''
        websocket = mapping['websocket']

        domain = "#{mapping['prefix']}.#{domain_root}"
        # compute base as prefix may have contained subdomains too
        domain_base = domain.gsub(/^[-a-z]+\./, '')

        file.write <<-EOS
server {
  listen #{port};
  server_name #{domain};

EOS
        if ssl
            file.write <<-EOS

    location #{websocket}/ {
      proxy_pass http://localhost:#{mapping['port']}#{websocket}/;
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
    }
EOS
        end

	file.write <<-EOS

  location / {
    proxy_pass http://localhost:#{mapping['port']}#{path};
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_redirect default;
  }

EOS

        if ssl
            file.write <<-EOS
  ssl on;
  ssl_certificate     star.#{domain_base}.chained.crt;
  ssl_certificate_key star.#{domain_base}.key;

  ssl_session_timeout 5m;

  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_ciphers HIGH:!aNULL:!MD5;
  ssl_prefer_server_ciphers on;
EOS
        end

        file.write <<-EOS
}

EOS

        if ssl
          file.write <<-EOS
server {
  listen 80;
  server_name #{domain};

  # redirect all HTTP traffic to HTTPS
  return 301 https://$host$request_uri;
}

EOS
        end

    end
end


`./restart-nginx.sh`
