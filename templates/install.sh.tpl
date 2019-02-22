#!/usr/bin/env bash

echo "Installing dependencies ..."
apt-get update
apt-get install -y unzip curl

echo "Installing Consul version ${consul_version} ..."
curl -s -O ${binary_uri}/${binary_filename} --output consul.zip

unzip consul.zip
chown root:root consul
chmod 0755 consul
mv consul /usr/local/bin