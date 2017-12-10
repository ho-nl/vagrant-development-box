#!/bin/bash

set -e

echo "🔥  Ensuring Varnish is disabled"

# Create a vcl that tells Varnish to cache nothing
cat > /etc/varnish/default.vcl <<- EOM
vcl 4.0;
backend default {
   .host = "127.0.0.1";
   .port = "8080";
}

sub vcl_recv {
   return(pass);
}
EOM

service varnish restart
