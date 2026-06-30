#!/usr/bin/env bash
set -euo pipefail

FNPACK_VERSION="${FNPACK_VERSION:-1.2.1}"
FNPACK_BASE_URL="${FNPACK_BASE_URL:-https://static2.fnnas.com/fnpack}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_DIR="${ROOT_DIR}/.fnpack"
BUILD_DIR="fnpack-root"
MANIFEST_FILE="${ROOT_DIR}/${BUILD_DIR}/manifest"

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

read_manifest_field() {
  local field="$1"

  awk -F '=' -v key="${field}" '
    $1 ~ "^[[:space:]]*" key "[[:space:]]*$" {
      value = $2
      sub(/^[[:space:]]+/, "", value)
      sub(/[[:space:]]+$/, "", value)
      print value
      exit
    }
  ' "${MANIFEST_FILE}"
}

rename_output_package() {
  local appname="$1"
  local version="$2"
  local source_path
  local output_ext
  local target_path

  for output_ext in fpk apk; do
    source_path="${ROOT_DIR}/${appname}.${output_ext}"
    if [ -f "${source_path}" ]; then
      target_path="${ROOT_DIR}/${appname}-${version}.${output_ext}"
      mv -f "${source_path}" "${target_path}"
      printf 'Renamed output package to %s\n' "${target_path}"
      return 0
    fi
  done

  printf 'Expected output package not found: %s.{fpk,apk}\n' "${appname}" >&2
  return 1
}

main() {
  local os
  local arch
  local fnpack_name
  local fnpack_path
  local fnpack_url
  local appname
  local version

  if ! command -v curl >/dev/null 2>&1; then
    printf 'curl is required to download fnpack.\n' >&2
    return 1
  fi

  cd "${ROOT_DIR}"

  if [ ! -d "${BUILD_DIR}" ]; then
    printf 'Build directory not found: %s\n' "${ROOT_DIR}/${BUILD_DIR}" >&2
    return 1
  fi

  if [ ! -r "${MANIFEST_FILE}" ]; then
    printf 'Manifest file not found: %s\n' "${MANIFEST_FILE}" >&2
    return 1
  fi

  appname="$(read_manifest_field appname)"
  version="$(read_manifest_field version)"
  if [ -z "${appname}" ] || [ -z "${version}" ]; then
    printf 'Manifest must contain appname and version fields: %s\n' "${MANIFEST_FILE}" >&2
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
  "${fnpack_path}" build --directory "${BUILD_DIR}" "$@"
  rename_output_package "${appname}" "${version}"
}

main "$@"
