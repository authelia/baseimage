#!/usr/bin/env bash

# Records the dependency versions of a Dockerfile bump in the README.md version history.
#
# Renovate cannot do this itself: postUpgradeTasks is a self-hosted only feature and a custom manager
# can only rewrite a version where it already appears, never add a dated entry. The Dockerfile ARGs on
# this branch are therefore compared against the base branch here, and the version list is rebuilt from
# the base branch's list so that repeated runs over a force pushed Renovate branch are idempotent.
#
# Usage: version-history.sh [base-ref]

set -euo pipefail

BASE_REF="${1:-origin/master}"
DATE="${VERSION_HISTORY_DATE:-$(date +%d/%m/%Y)}"
DOCKERFILE="Dockerfile"
README="README.md"

# The dependencies recorded in the version history, in the order an entry lists them.
DEPS=(
  "busybox:BUSYBOX_VERSION"
  "chisel:CHISEL_RELEASE"
  "su-exec:SUEXEC_RELEASE"
)

# arg_value <dockerfile-contents> <arg-name>
arg_value() {
  sed -nE "s/^ARG $2=\"?([^\"[:space:]]+)\"?.*\$/\1/p" <<< "$1" | head -n1
}

# entries <readme-contents> prints the version history entries, the list of "- " lines that follows the
# Version heading.
entries() {
  awk '/^## Version$/ { list = 1; next } list && /^- / { print; next } list { exit }' <<< "$1"
}

# join_parts <part>... renders "a", "a and b" or "a, b and c".
join_parts() {
  local last="${*: -1}"

  case $# in
    1) printf '%s' "${last}" ;;
    2) printf '%s and %s' "$1" "${last}" ;;
    *) printf '%s and %s' "$(IFS=, ; printf '%s' "${*:1:$#-1}" | sed 's/,/, /g')" "${last}" ;;
  esac
}

# message <dep=version>... renders the entry message for a set of versions, in DEPS order.
message() {
  local -A versions=()
  local pair parts=() dep

  for pair in "$@"; do
    versions["${pair%%=*}"]="${pair#*=}"
  done

  for dep in "${DEPS[@]%%:*}"; do
    [[ -v versions["${dep}"] ]] && parts+=("${dep} to v${versions["${dep}"]}")
  done

  printf 'Update %s' "$(join_parts "${parts[@]}")"
}

# versions_of <message> prints the "dep=version" pairs of an entry message, and fails when the message
# is not one this script can extend.
versions_of() {
  local dep version

  [[ $1 =~ ^Update\ (.+)$ ]] || return 1

  while read -r dep _ version; do
    [[ " ${DEPS[*]%%:*} " == *" ${dep} "* ]] || return 1
    [[ ${version} =~ ^v(.+)$ ]] || return 1

    printf '%s=%s\n' "${dep}" "${BASH_REMATCH[1]}"
  done <<< "$(sed -E 's/, / \n/g; s/ and / \n/g' <<< "${BASH_REMATCH[1]}")"
}

base_dockerfile="$(git show "${BASE_REF}:${DOCKERFILE}")"
base_readme="$(git show "${BASE_REF}:${README}")"

changes=()

for dep in "${DEPS[@]}"; do
  base_version="$(arg_value "${base_dockerfile}" "${dep##*:}")"
  version="$(arg_value "$(< "${DOCKERFILE}")" "${dep##*:}")"

  [[ -n ${version} && ${version} != "${base_version}" ]] && changes+=("${dep%%:*}=${version}")
done

if [[ ${#changes[@]} -eq 0 ]]; then
  echo "No tracked dependency changed against ${BASE_REF}."
  [[ -n ${GITHUB_OUTPUT:-} ]] && echo "changed=false" >> "${GITHUB_OUTPUT}"
  exit 0
fi

mapfile -t list < <(entries "${base_readme}")

# A same day entry is extended rather than duplicated, matching how the list has always recorded a day's
# changes on a single line.
if [[ ${list[0]:-} =~ ^-\ \*\*${DATE}:\*\*\ (.+)$ ]] && existing="$(versions_of "${BASH_REMATCH[1]}")"; then
  mapfile -t existing_versions <<< "${existing}"
  entry="- **${DATE}:** $(message "${existing_versions[@]}" "${changes[@]}")"
  list[0]="${entry}"
else
  entry="- **${DATE}:** $(message "${changes[@]}")"
  list=("${entry}" "${list[@]}")
fi

list_file="$(mktemp)"

printf '%s\n' "${list[@]}" > "${list_file}"

awk -v entries="${list_file}" '
  /^## Version$/ && !replaced {
    print
    while ((getline line < entries) > 0) print line
    replaced = list = 1
    next
  }
  list && /^- / { next }
  { list = 0; print }
' "${README}" > "${README}.new"

rm -f "${list_file}"
mv "${README}.new" "${README}"

echo "${entry}"

if [[ -n ${GITHUB_OUTPUT:-} ]]; then
  echo "changed=true" >> "${GITHUB_OUTPUT}"
  echo "entry=${entry}" >> "${GITHUB_OUTPUT}"
fi
