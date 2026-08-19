#!/bin/sh

set -eu

repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
destination=${OXIDE_EFFECTS_DESTINATION:-"$repository_root/Oxide-Effects"}
source_checkout=${1:-}
temporary_checkout=

cleanup() {
    if [ -n "$temporary_checkout" ]; then
        rm -rf "$temporary_checkout"
    fi
}
trap cleanup EXIT HUP INT TERM

if [ -e "$destination" ]; then
    echo "error: effects destination already exists: $destination" >&2
    exit 1
fi

if [ -z "$source_checkout" ]; then
    temporary_checkout=$(mktemp -d "${TMPDIR:-/tmp}/oxide-effects.XXXXXX")
    git clone --depth 1 \
        https://github.com/mentalparalyse/Oxide-Effects.git \
        "$temporary_checkout/repository"
    source_checkout="$temporary_checkout/repository"
fi

if [ ! -f "$source_checkout/Package.swift" ]; then
    echo "error: Oxide-Effects Package.swift not found in $source_checkout" >&2
    exit 1
fi

mkdir -p "$destination"
cp -R "$source_checkout"/. "$destination"

echo "Installed private effects package into $destination"
