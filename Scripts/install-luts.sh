#!/bin/sh

set -eu

repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
destination=${OXIDE_LUT_DESTINATION:-"$repository_root/OxideModules/Sources/ImageProcessor/LUTs"}
source_checkout=${1:-}
temporary_checkout=

cleanup() {
    if [ -n "$temporary_checkout" ]; then
        rm -rf "$temporary_checkout"
    fi
}
trap cleanup EXIT HUP INT TERM

if [ -z "$source_checkout" ]; then
    temporary_checkout=$(mktemp -d "${TMPDIR:-/tmp}/oxide-luts.XXXXXX")
    git clone --depth 1 \
        https://github.com/mentalparalyse/Oxide-LUTs.git \
        "$temporary_checkout/repository"
    source_checkout="$temporary_checkout/repository"
fi

source_directory="$source_checkout/LUTs"
if [ ! -d "$source_directory" ]; then
    echo "error: LUT source directory not found: $source_directory" >&2
    exit 1
fi

lut_count=$(find "$source_directory" -maxdepth 1 -type f -name '*.png' | wc -l | tr -d ' ')
if [ "$lut_count" -eq 0 ]; then
    echo "error: no LUT PNG files found in $source_directory" >&2
    exit 1
fi

mkdir -p "$destination"
find "$source_directory" -maxdepth 1 -type f -name '*.png' \
    -exec cp -f {} "$destination" \;

echo "Installed $lut_count LUT assets into $destination"
