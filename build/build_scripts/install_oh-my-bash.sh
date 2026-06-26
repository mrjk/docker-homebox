#!/bin/bash

# Install latest docker for debian

set -eu -o pipefail

>&2 echo "Installing Oh-my-bash ..."

[[ ! -d "/usr/share/oh-my-bash" ]] || rm -rf /usr/share/oh-my-bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --prefix=/usr --unattended

[[ -f /usr/share/oh-my-bash/oh-my-bash.sh ]] || >&2 echo "Failed to install oh-my-bash"

>&2 echo "Oh-my-bash installed and configured"

