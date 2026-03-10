#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:-}"
TABLE="filter"
FAMILY_V4="ip"
FAMILY_V6="ip6"
CHAIN="DOCKER-USER"
SANDBOX_CHAIN="codex_sandbox"
SET_NAME="codex_docker_bridges"
RULE_COMMENT="codex_sandbox"

require_root() {
  if [[ "$(id -u)" -ne 0 ]]; then
    echo "error: this script must be run as root." >&2
    exit 1
  fi
}

remove_rule_by_comment() {
  local family="$1"
  if nft list chain "${family}" "${TABLE}" "${CHAIN}" >/dev/null 2>&1; then
    nft -a list chain "${family}" "${TABLE}" "${CHAIN}" \
      | awk -v cmt="${RULE_COMMENT}" '/comment/ && $0 ~ cmt {print $NF}' \
      | while read -r handle; do
          [[ -n "${handle}" ]] && nft delete rule "${family}" "${TABLE}" "${CHAIN}" handle "${handle}"
        done
  fi
}

discover_bridges() {
  local bridges=()
  if command -v docker >/dev/null 2>&1; then
    while IFS= read -r net; do
      [[ -z "${net}" ]] && continue
      local br
      br="$(docker network inspect -f '{{index .Options "com.docker.network.bridge.name"}}' "${net}" 2>/dev/null || true)"
      if [[ -z "${br}" ]]; then
        if [[ "${net}" == "bridge" ]]; then
          br="docker0"
        fi
      fi
      [[ -n "${br}" ]] && bridges+=("${br}")
    done < <(docker network ls --filter driver=bridge --format '{{.Name}}' 2>/dev/null || true)
  fi

  if [[ "${#bridges[@]}" -eq 0 ]]; then
    bridges=("docker0")
  fi

  printf '%s\n' "${bridges[@]}" | awk '!seen[$0]++'
}

ensure_chain() {
  local family="$1"
  nft list chain "${family}" "${TABLE}" "${CHAIN}" >/dev/null 2>&1 || {
    nft add table "${family}" "${TABLE}" >/dev/null 2>&1 || true
    nft add chain "${family}" "${TABLE}" "${CHAIN}" >/dev/null 2>&1 || true
  }
}

apply_rules() {
  require_root

  ensure_chain "${FAMILY_V4}"
  ensure_chain "${FAMILY_V6}"

  local elements=""
  while IFS= read -r br; do
    elements+=\""${br}"\", 
  done < <(discover_bridges)
  elements="${elements%, }"

  nft add set "${FAMILY_V4}" "${TABLE}" "${SET_NAME}" '{ type ifname; }' >/dev/null 2>&1 || true
  nft flush set "${FAMILY_V4}" "${TABLE}" "${SET_NAME}"
  nft add element "${FAMILY_V4}" "${TABLE}" "${SET_NAME}" "{ ${elements} }"
  nft add chain "${FAMILY_V4}" "${TABLE}" "${SANDBOX_CHAIN}" >/dev/null 2>&1 || true
  nft flush chain "${FAMILY_V4}" "${TABLE}" "${SANDBOX_CHAIN}"
  remove_rule_by_comment "${FAMILY_V4}"

  nft add rule "${FAMILY_V4}" "${TABLE}" "${CHAIN}" iifname @"${SET_NAME}" jump "${SANDBOX_CHAIN}" comment "${RULE_COMMENT}"
  nft add rule "${FAMILY_V4}" "${TABLE}" "${SANDBOX_CHAIN}" ip daddr '{ 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 127.0.0.0/8, 169.254.0.0/16, 224.0.0.0/4 }' drop

  nft add set "${FAMILY_V6}" "${TABLE}" "${SET_NAME}" '{ type ifname; }' >/dev/null 2>&1 || true
  nft flush set "${FAMILY_V6}" "${TABLE}" "${SET_NAME}"
  nft add element "${FAMILY_V6}" "${TABLE}" "${SET_NAME}" "{ ${elements} }"
  nft add chain "${FAMILY_V6}" "${TABLE}" "${SANDBOX_CHAIN}" >/dev/null 2>&1 || true
  nft flush chain "${FAMILY_V6}" "${TABLE}" "${SANDBOX_CHAIN}"
  remove_rule_by_comment "${FAMILY_V6}"

  nft add rule "${FAMILY_V6}" "${TABLE}" "${CHAIN}" iifname @"${SET_NAME}" jump "${SANDBOX_CHAIN}" comment "${RULE_COMMENT}"
  nft add rule "${FAMILY_V6}" "${TABLE}" "${SANDBOX_CHAIN}" ip6 daddr '{ ::1/128, fc00::/7, fe80::/10, ff00::/8 }' drop
}

remove_rules() {
  require_root
  remove_rule_by_comment "${FAMILY_V4}"
  remove_rule_by_comment "${FAMILY_V6}"
  nft delete chain "${FAMILY_V4}" "${TABLE}" "${SANDBOX_CHAIN}" >/dev/null 2>&1 || true
  nft delete chain "${FAMILY_V6}" "${TABLE}" "${SANDBOX_CHAIN}" >/dev/null 2>&1 || true
  nft delete set "${FAMILY_V4}" "${TABLE}" "${SET_NAME}" >/dev/null 2>&1 || true
  nft delete set "${FAMILY_V6}" "${TABLE}" "${SET_NAME}" >/dev/null 2>&1 || true
}

status_rules() {
  nft list chain "${FAMILY_V4}" "${TABLE}" "${CHAIN}" 2>/dev/null || true
  nft list chain "${FAMILY_V6}" "${TABLE}" "${CHAIN}" 2>/dev/null || true
  nft list chain "${FAMILY_V4}" "${TABLE}" "${SANDBOX_CHAIN}" 2>/dev/null || true
  nft list chain "${FAMILY_V6}" "${TABLE}" "${SANDBOX_CHAIN}" 2>/dev/null || true
  nft list set "${FAMILY_V4}" "${TABLE}" "${SET_NAME}" 2>/dev/null || true
  nft list set "${FAMILY_V6}" "${TABLE}" "${SET_NAME}" 2>/dev/null || true
}

case "${ACTION}" in
  apply)
    apply_rules
    ;;
  remove)
    remove_rules
    ;;
  status)
    status_rules
    ;;
  *)
    echo "usage: $0 apply|remove|status" >&2
    exit 2
    ;;
esac
