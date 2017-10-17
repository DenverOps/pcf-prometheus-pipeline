#!/bin/bash

mkdir params || true
rm -f params/params.yml

CURL="om --target https://${opsman_url} -k \
  --username ${pcf_opsman_admin_username} \
  --password ${pcf_opsman_admin_password} \
  curl"

cf_id=$($CURL --path=/api/v0/deployed/products | jq -r '.[] | select(.type == "cf") | .guid')

system_domain=$($CURL --path=/api/v0/deployed/products/$cf_id/manifest | jq -r '.instance_groups[] | select (.name == "cloud_controller") | .jobs[] | select (.name == "cloud_controller_ng") | .properties.system_domain')
echo "system_domain: ${system_domain}" >> params/params.yml

doppler_url=$($CURL --path=/api/v0/deployed/products/$cf_id/manifest | jq -r '.instance_groups[] | select(.name == "autoscaling") | .jobs[] | select (.name == "deploy-autoscaling") | .properties.doppler.host')
traffic_controller_external_port=${doppler_url/*:/}
echo "traffic_controller_external_port: ${traffic_controller_external_port}" >> params/params.yml