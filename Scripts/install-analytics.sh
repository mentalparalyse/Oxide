#!/bin/sh

set -eu

repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
destination=${OXIDE_ANALYTICS_DESTINATION:-"$repository_root/Oxide-Analytics"}
source_checkout=${1:-}
temporary_checkout=

cleanup() {
    if [ -n "$temporary_checkout" ]; then
        rm -rf "$temporary_checkout"
    fi
}
trap cleanup EXIT HUP INT TERM

if [ -e "$destination" ]; then
    echo "error: analytics destination already exists: $destination" >&2
    exit 1
fi

if [ -z "$source_checkout" ]; then
    temporary_checkout=$(mktemp -d "${TMPDIR:-/tmp}/oxide-analytics.XXXXXX")
    git clone --depth 1 \
        https://github.com/mentalparalyse/Oxide-Analytics.git \
        "$temporary_checkout/repository"
    source_checkout="$temporary_checkout/repository"
fi

if [ ! -f "$source_checkout/Package.swift" ]; then
    echo "error: Oxide-Analytics Package.swift not found in $source_checkout" >&2
    exit 1
fi

mkdir -p "$destination"
rsync -a --exclude '.build/' "$source_checkout"/ "$destination"/

echo "Installed private analytics package into $destination"
