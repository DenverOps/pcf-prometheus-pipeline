#!/bin/bash

mkdir params || true
rm -f params/params.yml

CURL="om --target https://${opsman_url} -k \
  --username ${pcf_opsman_admin_username} \
  --password ${pcf_opsman_admin_password} \
  curl"

cf_id=$($CURL --path=/api/v0/deployed/products | jq -r '.[] | select(.type == "cf") | .guid')

$CURL --path=/api/v0/deployed/products/$cf_id/manifest > /tmp/cf-manifest.yml

system_domain=$(jq -r '.instance_groups[] | select (.name == "cloud_controller") | .jobs[] | select (.name == "cloud_controller_ng") | .properties.system_domain' < /tmp/cf-manifest.yml)
echo "system_domain: ${system_domain}" >> params/params.yml

doppler_url=$(jq -r '.instance_groups[] | select(.name == "autoscaling") | .jobs[] | select (.name == "deploy-autoscaling") | .properties.doppler.host' < /tmp/cf-manifest.yml)
traffic_controller_external_port=${doppler_url/*:/}
echo "traffic_controller_external_port: ${traffic_controller_external_port}" >> params/params.yml