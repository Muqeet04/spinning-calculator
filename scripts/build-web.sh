#!/usr/bin/env bash
set -euo pipefail

# Match the SDK used by the Android release workflow and dependency lockfile.
flutter_version=3.47.7
flutter_sdk_dir="${FLUTTER_SDK_DIR:-${TMPDIR:-/tmp}/mm-flutter-$flutter_version}"

if [[ ! -x "$flutter_sdk_dir/bin/flutter" ]]; then
  git clone --depth 1 --branch "$flutter_version" \
    https://github.com/flutter/flutter.git "$flutter_sdk_dir"
fi

export CI=true
export FLUTTER_SUPPRESS_ANALYTICS=true
export DART_SUPPRESS_ANALYTICS=true
"$flutter_sdk_dir/bin/flutter" config --no-analytics --enable-web
"$flutter_sdk_dir/bin/flutter" pub get --enforce-lockfile
"$flutter_sdk_dir/bin/flutter" build web --release --no-pub

# Allow the live site to identify exactly which source revision it serves.
commit_sha="${VERCEL_GIT_COMMIT_SHA:-$(git rev-parse HEAD)}"
printf '{"commit":"%s"}\n' "$commit_sha" > build/web/deployment.json
