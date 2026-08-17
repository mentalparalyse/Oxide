#!/bin/sh

set -eu

repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
installer="$repository_root/Scripts/install-luts.sh"
test_root=$(mktemp -d "${TMPDIR:-/tmp}/oxide-luts-test.XXXXXX")

cleanup() {
    rm -rf "$test_root"
}
trap cleanup EXIT HUP INT TERM

mkdir -p "$test_root/source/LUTs"
printf 'fixture' > "$test_root/source/LUTs/test-lut.png"

destination="$test_root/destination"
OXIDE_LUT_DESTINATION="$destination" "$installer" "$test_root/source"

test -f "$destination/test-lut.png"

if OXIDE_LUT_DESTINATION="$destination" \
    "$installer" "$test_root/missing" >/dev/null 2>&1; then
    echo "error: installer accepted a missing LUT source" >&2
    exit 1
fi

mkdir -p "$test_root/empty/LUTs"
if OXIDE_LUT_DESTINATION="$destination" \
    "$installer" "$test_root/empty" >/dev/null 2>&1; then
    echo "error: installer accepted an empty LUT source" >&2
    exit 1
fi

echo "install-luts tests passed"
