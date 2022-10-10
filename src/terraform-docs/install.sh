#!/bin/sh
set -e

echo "Activating feature 'Terraform Docs'"

TERRAFORM_DOCS_VERSION="${VERSION:-"latest"}"

architecture="$(uname -m)"
case ${architecture} in
    x86_64) architecture="amd64";;
    aarch64 | armv8*) architecture="arm64";;
    aarch32 | armv7* | armvhf*) architecture="arm";;
    i?86) architecture="386";;
    *) echo "(!) Architecture ${architecture} unsupported"; exit 1 ;;
esac

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/' |
    tr -d 'v'
}

if [[ ${TERRAFORM_DOCS_VERSION} == "latest" ]]; then
  TERRAFORM_DOCS_VERSION=$(get_latest_release 'terraform-docs/terraform-docs')
fi

mkdir -p /tmp/tf-downloads
cd /tmp/tf-downloads

echo "Downloading terraform-docs..."

TERRAFORM_DOCS_filename="terraform-docs-v${TERRAFORM_DOCS_VERSION}_linux_${architecture}.tar.gz"
TERRAFORM_DOCS_url="https://terraform-docs.io/dl/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-${architecture}.tar.gz"

curl -sSL -o ${TERRAFORM_DOCS_filename} ${TERRAFORM_DOCS_url}

tar -xzf ${TERRAFORM_DOCS_filename}
mv terraform-docs /usr/local/bin/terraform-docs

chmod +x /usr/local/bin/terraform-docs

rm -rf /tmp/tf-downloads