#!/bin/sh
# 카드 12장을 4x3 한 장으로 모아 preview.png 생성 (줄바꿈·잘림 확인용)
# vertical/ 이 있으면 9:16 영상용 카드도 preview-vertical.png 로 만든다
# usage: sh preview.sh <workdir>
set -e
cd "$1"
L="xstack=inputs=12:layout=0_0|w0_0|w0+w1_0|w0+w1+w2_0|0_h0|w0_h0|w0+w1_h0|w0+w1+w2_h0|0_h0+h4|w0_h0+h4|w0+w1_h0+h4|w0+w1+w2_h0+h4,scale=2160:-1"
args=""; for g in A B C; do for i in 1 2 3 4; do args="$args -i $g-0$i.png"; done; done
ffmpeg -loglevel error -y $args -filter_complex "$L" -frames:v 1 preview.png
echo "preview.png"
if [ -f vertical/C-04.png ]; then
  args=""; for g in A B C; do for i in 1 2 3 4; do args="$args -i vertical/$g-0$i.png"; done; done
  ffmpeg -loglevel error -y $args -filter_complex "$L" -frames:v 1 preview-vertical.png
  echo "preview-vertical.png"
fi
