#!/usr/bin/env bash

# .buildkite/libs/common.sh
#
# Shared helpers for the pipeline generator and the post-command hook.
# Source with a BASH_SOURCE-relative path so it works regardless of CWD:
#   source "$(dirname "${BASH_SOURCE[0]}")/libs/common.sh"        # from .buildkite/
#   source "$(dirname "${BASH_SOURCE[0]}")/../libs/common.sh"     # from .buildkite/hooks/

# Makes a branch name safe to use in a Docker tag. A Docker tag admits only [A-Za-z0-9_.-], so the "/" in the
# "<type>/<summary>" branch convention (and anything else out of that set) is folded down to "-": fix/libgcc-s1
# becomes fix-libgcc-s1. Applied line by line, so a list of branch names can be passed in one call.
#
# Every place that turns a branch name into a tag must agree on this mapping, including the ones outside this file:
# the tag reaper in hooks/post-command, which compares the published tags against the live branch names, and the
# announcement in .github/probot.js, which tells contributors the tag their branch publishes under.
sanitize_tag() {
  echo "${1}" | sed -E 's/[^A-Za-z0-9_.-]+/-/g'
}
