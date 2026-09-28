#!/bin/bash
set -euo pipefail
test_dir="$(cd "$(dirname "$0")" && pwd)"
avatar_dir="$test_dir/../WuKongBase/Classes/Sections/Conversation/Avatar"
build_dir="$(mktemp -d "${TMPDIR:-/tmp}/wk-avatar-tests.XXXXXX")"
trap 'rm -rf "$build_dir"' EXIT
xcrun --sdk macosx clang -fobjc-arc -Wall -Wextra -Werror \
  -framework Foundation -framework CoreGraphics -I "$avatar_dir" \
  "$avatar_dir/WKMessageAvatarLayout.m" "$test_dir/AvatarLayoutTests.m" \
  -o "$build_dir/avatar-tests"
"$build_dir/avatar-tests"
