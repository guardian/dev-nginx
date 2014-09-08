#!/usr/bin/env ruby

require 'yaml'

if ARGV.size != 1
    puts "usage: install-app.rb <config.yml>"
    exit(1)
end

DOMAIN_ROOT = "local.dev-gutools.co.uk"
NGINX_DIR = `./locate-nginx.sh`.chomp

config_file = ARGV[0]

config = YAML.load_file(config_file)

dest = File.join(NGINX_DIR, "sites-enabled", "#{config['name']}.conf")
file = File.open(dest, 'w')

config['mappings'].each do |mapping|

file.write <<-EOS
server {
  listen 443;
  server_name #{mapping['prefix']}.#{DOMAIN_ROOT};

  ssl on;
  ssl_certificate local.crt;
  ssl_certificate_key local.key;

  ssl_session_timeout 5m;

  ssl_protocols SSLv2 SSLv3 TLSv1;
  ssl_ciphers HIGH:!aNULL:!MD5;
  ssl_prefer_server_ciphers on;

  location / {
    proxy_pass http://localhost:#{mapping['port']};
  }
}

EOS

end

file.close
