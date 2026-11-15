#!/bin/sh
# Figma 사진 레이어 채우기: assets/{key}.png → 1600px JPEG → upload URL 로 동시 POST
# usage: sh figma-upload.sh <workdir> <urls.txt>
#   urls.txt 한 줄에 "<key> <submitUrl>" (예: "A1 https://mcp.figma.com/...") — upload_assets(nodeIds=사진 레이어 ID들) 결과로 만든다
# URL 은 10분 뒤 만료되므로 동시에 보낸다(11-12: 직렬로 보냈더니 3장 뒤 멈춤, 동시 9장은 4초). 200 이 아닌 키만 URL 을 새로 받아 다시 돌린다.
wd="$1"; list="$2"
tmp="$wd/publish/figma-jpg"; mkdir -p "$tmp"
while read -r key url; do
  [ -z "$key" ] && continue
  sips -s format jpeg -s formatOptions 85 -Z 1600 "$wd/assets/$key.png" --out "$tmp/$key.jpg" >/dev/null
  ( code=$(curl -s -m 540 -o "$tmp/$key.resp" -w '%{http_code}' -X POST -H "Content-Type: image/jpeg" --data-binary "@$tmp/$key.jpg" "$url"); echo "$key $code" ) &
done < "$list"
wait
