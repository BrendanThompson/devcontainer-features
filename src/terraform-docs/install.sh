#!/bin/sh
set -e

echo "Activating feature 'Terraform Docs'"

curl -sSLo ./terraform-docs.tar.gz https://terraform-docs.io/dl/v0.16.0/terraform-docs-v0.16.0-$(uname)-amd64.tar.gz
tar -xzf terraform-docs.tar.gz
mv terraform-docs /usr/local/bin/terraform-docs

chmod +x /usr/local/bin/terraform-docs