#!/bin/bash


urls=("https://www.whatap.io"  "https://blog.whatap.io"  "https://service.whatap.io")
 
for url in ${urls[*]}; do

echo "M $url url $url"
curl -w @- -o /dev/null -s "$url" <<'EOF'
H %{url_effective} time_namelookup %{time_namelookup}\n
H %{url_effective} time_connect %{time_connect}\n
H %{url_effective} time_appconnect %{time_appconnect}\n
H %{url_effective} time_pretransfer %{time_pretransfer}\n
H %{url_effective} time_redirect %{time_redirect}\n
H %{url_effective} time_starttransfer %{time_starttransfer}\n
H %{url_effective} time_total %{time_total}\n
EOF


done
