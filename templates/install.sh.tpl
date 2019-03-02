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

echo "Creating Consul service account ..."
useradd -r -d /etc/consul.d -s /bin/false consul

echo "Creating Consul directory structure ..."
mkdir /etc/consul{,.d}
chown root:consul /etc/consul{,.d}
chmod 0750 /etc/consul{,.d}

mkdir /var/lib/consul
chown consul:consul /var/lib/consul
chmod 0750 /var/lib/consul

echo "Creating Consul config ..."
HOSTNAME=$(hostname -s)

cat > /etc/consul.d/consul.json << EOF
{
  "datacenter": "${datacenter}",
  "data_dir": "${data_dir}",
  "log_level": "${log_level}",
  "node_name": "${HOSTNAME}",
  "server": true,
  "advertise_addr": "${IP_ADDRESS}"
  "client_addr": "${"
  "enable_syslog": true,
  "ui": true,
}