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
name = config['name']
ssl = config.key?('ssl') ? config['ssl'] : true
port = ssl ? 443 : 80

dest = File.join(NGINX_DIR, "sites-enabled", "#{name}.conf")

file = File.open(dest, 'w') do |file|

    config['mappings'].each do |mapping|

        file.write <<-EOS
server {
  listen #{port};
  server_name #{mapping['prefix']}.#{DOMAIN_ROOT};

  location / {
    proxy_pass http://localhost:#{mapping['port']};
  }

EOS

        if ssl
            file.write <<-EOS
  ssl on;
  ssl_certificate     star.#{DOMAIN_ROOT}.crt;
  ssl_certificate_key star.#{DOMAIN_ROOT}.key;

  ssl_session_timeout 5m;

  ssl_protocols SSLv2 SSLv3 TLSv1;
  ssl_ciphers HIGH:!aNULL:!MD5;
  ssl_prefer_server_ciphers on;
EOS
        end

        file.write <<-EOS
}

EOS

    end
end


`./restart-nginx.sh`
