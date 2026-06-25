#!/usr/bin/env bash
set -euo pipefail

FNPACK_VERSION="${FNPACK_VERSION:-1.2.1}"
FNPACK_BASE_URL="${FNPACK_BASE_URL:-https://static2.fnnas.com/fnpack}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_DIR="${ROOT_DIR}/.fnpack"
BUILD_DIR="fnpack-root"

detect_os() {
  case "$(uname -s)" in
    Linux)
      printf 'linux'
      ;;
    Darwin)
      printf 'darwin'
      ;;
    *)
      printf 'Unsupported OS: %s\n' "$(uname -s)" >&2
      return 1
      ;;
  esac
}

detect_arch() {
  case "$(uname -m)" in
    x86_64 | amd64)
      printf 'amd64'
      ;;
    arm64 | aarch64)
      printf 'arm64'
      ;;
    *)
      printf 'Unsupported architecture: %s\n' "$(uname -m)" >&2
      return 1
      ;;
  esac
}

download_fnpack() {
  local fnpack_path="$1"
  local fnpack_url="$2"
  local tmp_path

  mkdir -p "${CACHE_DIR}"
  tmp_path="$(mktemp "${CACHE_DIR}/fnpack.XXXXXX")"
  trap 'rm -f "${tmp_path}"' EXIT

  printf 'Downloading %s\n' "${fnpack_url}"
  curl -fL --retry 3 --connect-timeout 20 -o "${tmp_path}" "${fnpack_url}"
  chmod 0755 "${tmp_path}"
  mv "${tmp_path}" "${fnpack_path}"

  trap - EXIT
}

main() {
  local os
  local arch
  local fnpack_name
  local fnpack_path
  local fnpack_url

  if ! command -v curl >/dev/null 2>&1; then
    printf 'curl is required to download fnpack.\n' >&2
    return 1
  fi

  cd "${ROOT_DIR}"

  if [ ! -d "${BUILD_DIR}" ]; then
    printf 'Build directory not found: %s\n' "${ROOT_DIR}/${BUILD_DIR}" >&2
    return 1
  fi

  os="$(detect_os)"
  arch="$(detect_arch)"
  fnpack_name="fnpack-${FNPACK_VERSION}-${os}-${arch}"
  fnpack_path="${CACHE_DIR}/${fnpack_name}"
  fnpack_url="${FNPACK_BASE_URL}/${fnpack_name}"

  if [ ! -s "${fnpack_path}" ]; then
    download_fnpack "${fnpack_path}" "${fnpack_url}"
  elif [ ! -x "${fnpack_path}" ]; then
    chmod 0755 "${fnpack_path}"
  fi

  printf 'Using %s\n' "${fnpack_path}"
  exec "${fnpack_path}" build --directory "${BUILD_DIR}" "$@"
}

main "$@"
