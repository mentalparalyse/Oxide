#!/bin/sh

set -eu

repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
installer="$repository_root/Scripts/install-effects.sh"
test_root=$(mktemp -d "${TMPDIR:-/tmp}/oxide-effects-test.XXXXXX")

cleanup() {
    rm -rf "$test_root"
}
trap cleanup EXIT HUP INT TERM

mkdir -p "$test_root/source/Sources/OxideEffects"
printf '// fixture\n' > "$test_root/source/Package.swift"
printf '// fixture\n' > "$test_root/source/Sources/OxideEffects/Effect.swift"

destination="$test_root/destination"
OXIDE_EFFECTS_DESTINATION="$destination" "$installer" "$test_root/source"

test -f "$destination/Package.swift"
test -f "$destination/Sources/OxideEffects/Effect.swift"

if OXIDE_EFFECTS_DESTINATION="$destination" \
    "$installer" "$test_root/source" >/dev/null 2>&1; then
    echo "error: installer overwrote an existing destination" >&2
    exit 1
fi

mkdir -p "$test_root/invalid"
if OXIDE_EFFECTS_DESTINATION="$test_root/invalid-destination" \
    "$installer" "$test_root/invalid" >/dev/null 2>&1; then
    echo "error: installer accepted a checkout without Package.swift" >&2
    exit 1
fi

echo "install-effects tests passed"
