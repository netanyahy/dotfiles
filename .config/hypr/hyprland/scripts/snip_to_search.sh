#!/usr/bin/env bash
geometry=$(slurp) || exit 0
[ -z "$geometry" ] && exit 0

grim -g "$geometry" /tmp/image.png || exit 0
[ -f /tmp/image.png ] || exit 0

imageLink=$(curl -sF files[]=@/tmp/image.png 'https://uguu.se/upload' | jq -r '.files[0].url')
if [ -n "$imageLink" ] && [ "$imageLink" != "null" ]; then
    xdg-open "https://lens.google.com/uploadbyurl?url=${imageLink}"
fi
rm -f /tmp/image.png
