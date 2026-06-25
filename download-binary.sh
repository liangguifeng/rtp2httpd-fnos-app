#!/usr/bin/env bash
set -euo pipefail

RTP2HTTPD_REPO="${RTP2HTTPD_REPO:-stackia/rtp2httpd}"
RTP2HTTPD_BASE_URL="${RTP2HTTPD_BASE_URL:-https://github.com/${RTP2HTTPD_REPO}/releases/download}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="${ROOT_DIR}/fnpack-root/manifest"
SERVER_DIR="${ROOT_DIR}/fnpack-root/app/server"
UPGRADE_DIR="${SERVER_DIR}/upgrade"
UPGRADE_INIT="${ROOT_DIR}/fnpack-root/cmd/upgrade_init"
ARCHES=(x86_64 aarch64)

read_manifest_version() {
  local version

  if [ ! -f "${MANIFEST}" ]; then
    printf 'Manifest not found: %s\n' "${MANIFEST}" >&2
    return 1
  fi

  version="$(awk -F'=' '/^[[:space:]]*version[[:space:]]*=/ {
    sub(/^[[:space:]]+/, "", $2)
    sub(/[[:space:]]+$/, "", $2)
    print $2
    exit
  }' "${MANIFEST}")"

  if [ -z "${version}" ]; then
    printf 'Failed to read version from manifest: %s\n' "${MANIFEST}" >&2
    return 1
  fi

  printf '%s' "${version}"
}

download_binary() {
  local version="$1"
  local arch="$2"
  local filename="rtp2httpd-${version}-${arch}"
  local url="${RTP2HTTPD_BASE_URL}/v${version}/${filename}"
  local dest="${UPGRADE_DIR}/${filename}"
  local tmp_path

  mkdir -p "${UPGRADE_DIR}"
  tmp_path="$(mktemp "${UPGRADE_DIR}/.${filename}.XXXXXX")"
  trap 'rm -f "${tmp_path}"' RETURN

  printf 'Downloading %s\n' "${url}"
  curl -fL --retry 3 --connect-timeout 20 -o "${tmp_path}" "${url}"
  chmod 0755 "${tmp_path}"
  mv "${tmp_path}" "${dest}"
  trap - RETURN

  printf 'Saved to %s\n' "${dest}"
}

install_binary() {
  local version="$1"
  local arch="$2"
  local src="${UPGRADE_DIR}/rtp2httpd-${version}-${arch}"
  local dest="${SERVER_DIR}/rtp2httpd-${arch}"

  cp -f "${src}" "${dest}"
  chmod 0755 "${dest}"
  printf 'Installed %s\n' "${dest}"
}

cleanup_old_binaries() {
  local version="$1"
  local filename

  for path in "${UPGRADE_DIR}"/rtp2httpd-*-*; do
    [ -e "${path}" ] || continue
    filename="$(basename "${path}")"

    case "${filename}" in
      "rtp2httpd-${version}-x86_64" | "rtp2httpd-${version}-aarch64")
        continue
      esac

    if [[ "${filename}" =~ ^rtp2httpd-[0-9]+\.[0-9]+\.[0-9]+-(x86_64|aarch64)$ ]]; then
      rm -f "${path}"
      printf 'Removed old binary: %s\n' "${path}"
    fi
  done
}

update_upgrade_init() {
  local version="$1"
  local tmp_path

  if [ ! -f "${UPGRADE_INIT}" ]; then
    printf 'upgrade_init not found: %s\n' "${UPGRADE_INIT}" >&2
    return 1
  fi

  tmp_path="$(mktemp)"
  sed -E "s/rtp2httpd-[0-9]+\.[0-9]+\.[0-9]+-/rtp2httpd-${version}-/g" \
    "${UPGRADE_INIT}" > "${tmp_path}"
  mv "${tmp_path}" "${UPGRADE_INIT}"

  printf 'Updated %s to version %s\n' "${UPGRADE_INIT}" "${version}"
}

main() {
  local version
  local arch

  if ! command -v curl >/dev/null 2>&1; then
    printf 'curl is required to download rtp2httpd binaries.\n' >&2
    return 1
  fi

  version="$(read_manifest_version)"
  printf 'Manifest version: %s\n' "${version}"

  for arch in "${ARCHES[@]}"; do
    download_binary "${version}" "${arch}"
    install_binary "${version}" "${arch}"
  done

  cleanup_old_binaries "${version}"
  update_upgrade_init "${version}"
}

main "$@"
