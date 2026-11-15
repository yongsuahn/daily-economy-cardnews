#!/bin/sh
# 카드 → 9:16 영상 (카드당 4초, 무음 오디오 트랙). 릴스·Shorts·TikTok 공용
# usage: sh make-video.sh <workdir> [A B C ...]
#   이슈 키를 주면 이슈마다 4장짜리 16초 영상 → publish/issue-<키>-16s.mp4 (2026-11-12 부터 이슈별 게시)
#   키를 안 주면 A B C 셋 다 만든다.
#   2026-11-15 부터 render.swift 가 만든 vertical/<키>-0N.png(1080x1920, 화면 꽉 채움)를 쓴다.
#   vertical/ 이 없으면 예전 방식(4:5 카드 + 흐린 배경)으로 만든다.
set -e
cd "$1"; shift; mkdir -p publish
keys="$*"; [ -z "$keys" ] && keys="A B C"
for g in $keys; do
  inputs=""; fc=""; cat=""
  if [ -f "vertical/$g-01.png" ]; then
    for i in 1 2 3 4; do inputs="$inputs -loop 1 -t 4 -i vertical/$g-0$i.png"; done
    for n in 0 1 2 3; do fc="${fc}[${n}:v]scale=1080:1920,setsar=1,fps=30[v${n}];"; cat="${cat}[v${n}]"; done
  else
    for i in 1 2 3 4; do inputs="$inputs -loop 1 -t 4 -i $g-0$i.png"; done
    for n in 0 1 2 3; do
      fc="${fc}[${n}:v]split[a${n}][b${n}];[a${n}]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,gblur=sigma=40,eq=brightness=-0.08[bg${n}];[b${n}]scale=1080:-1[fg${n}];[bg${n}][fg${n}]overlay=(W-w)/2:(H-h)/2,setsar=1,fps=30[v${n}];"
      cat="${cat}[v${n}]"
    done
  fi
  ffmpeg -loglevel error -y $inputs -f lavfi -t 16 -i anullsrc=r=48000:cl=stereo -filter_complex "${fc}${cat}concat=n=4:v=1:a=0[v]" -map "[v]" -map 4:a -c:v libx264 -pix_fmt yuv420p -crf 20 -c:a aac -b:a 128k -shortest "publish/issue-$g-16s.mp4"
  echo "publish/issue-$g-16s.mp4"
done
