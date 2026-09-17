#!/usr/bin/env bash
set -euo pipefail

APP_REMOTE="appcenter"
APP_URL="https://flatpak.elementaryos.org/repo"
FLAT_REMOTE="flathub"
FLAT_URL="https://flathub.org/repo/flathub.flatpakrepo"

if ! command -v flatpak >/dev/null 2>&1; then
  echo "flatpak is not installed. Install it first, then re-run this script."
  exit 1
fi

add_remote() {
  local name="$1"
  local url="$2"
  if flatpak remote-list 2>/dev/null | grep -qi "^${name}[[:space:]]"; then
    echo "Remote '${name}' already exists. Skipping."
  else
    if [[ "${name}" == "appcenter" ]]; then
      local keyfile="${XDG_DATA_HOME:-$HOME/.local/share}/flatpak/repo/${name}.trustedkeys.gpg"
      local candidate=""
      for candidate in \
        "${keyfile}" \
        /etc/flatpak/remote/"${name}".trustedkeys.gpg \
        /usr/share/flatpak/remote/"${name}".trustedkeys.gpg; do
        if [[ -f "${candidate}" ]]; then
          flatpak remote-add --user --gpg-import="${candidate}" "${name}" "${url}" && break
        fi
      done
      if ! flatpak remote-list 2>/dev/null | grep -qi "^${name}[[:space:]]"; then
        echo "GPG key not found for '${name}'. Adding without signature verification."
        flatpak remote-add --user --no-gpg-verify --if-not-exists "${name}" "${url}"
      fi
    else
      flatpak remote-add --user --if-not-exists "${name}" "${url}"
    fi
    echo "Added remote '${name}' (${url})."
  fi
}

add_remote "${APP_REMOTE}" "${APP_URL}"
add_remote "${FLAT_REMOTE}" "${FLAT_URL}"

echo "Done. Available remotes:"
flatpak remote-list
