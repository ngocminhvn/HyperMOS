#!/usr/bin/env bash
# Download public GitHub release assets using authenticated gh when available.
# Never put tokens into URLs or forward Authorization headers to CDNs.
# Usage: github_release_download owner/repo tag asset destination
github_release_download() {
  if (( $# != 4 )); then
    echo "[ERROR] github_release_download requires repo, tag, asset, destination" >&2
    return 2
  fi
  local repo="$1" tag="$2" asset="$3" destination="$4"
  if [[ ! "$repo" =~ ^[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+$ ]] ||
     [[ ! "$tag" =~ ^[a-zA-Z0-9_.+-]+$ ]] ||
     [[ ! "$asset" =~ ^[a-zA-Z0-9_.+@-]+$ ]]; then
    echo "[ERROR] Invalid GitHub release coordinates" >&2
    return 2
  fi
  mkdir -p "$(dirname "$destination")" || return 1
  local temp_dir token status
  temp_dir="$(mktemp -d)" || return 1
  token="${GH_TOKEN:-${GITHUB_TOKEN:-}}"
  if [[ -n "$token" ]] && command -v gh >/dev/null 2>&1; then
    if GH_TOKEN="$token" gh release download "$tag" --repo "$repo" \
        --pattern "$asset" --dir "$temp_dir" --clobber >/dev/null 2>&1 &&
        [[ -s "$temp_dir/$asset" ]]; then
      mv -f "$temp_dir/$asset" "$destination"
      status=$?
      rm -rf "$temp_dir"
      return "$status"
    fi
    echo "[WARN] Authenticated GitHub release download failed for $repo/$tag/$asset; trying public URL" >&2
  fi
  local public_url="https://github.com/$repo/releases/download/$tag/$asset"
  if curl -fsSL --retry 3 --retry-delay 2 --retry-all-errors \
      --connect-timeout 20 -o "$temp_dir/$asset" "$public_url" &&
      [[ -s "$temp_dir/$asset" ]]; then
    mv -f "$temp_dir/$asset" "$destination"
    status=$?
    rm -rf "$temp_dir"
    return "$status"
  fi
  rm -rf "$temp_dir"
  return 1
}
