#!/usr/bin/env bash
set -e

TERRAFORM_LS_VERSION="${VERSION:-"latest"}"

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

if [[ ${TERRAFORM_LS_VERSION} == "latest" ]]; then
  TERRAFORM_LS_VERSION=$(get_latest_release 'hashicorp/terraform-ls')
fi

mkdir -p /tmp/tf-downloads
cd /tmp/tf-downloads

echo "Downloading terraform-ls..."

terraform_ls_filename="terraform-ls_${TERRAFORM_LS_VERSION}_linux_${architecture}.zip"
terraform_ls_url="https://github.com/hashicorp/terraform-ls/releases/download/v${TERRAFORM_LS_VERSION}/terraform-ls_${TERRAFORM_LS_VERSION}_linux_${architecture}.zip"

curl -sSL -o ${terraform_ls_filename} ${terraform_ls_url}

unzip ${terraform_ls_filename}
mv terraform-ls /usr/local/bin/terraform-ls

chmod +x /usr/local/bin/terraform-ls

rm -rf /tmp/tf-downloads