#!/bin/sh
echo "=== DEBUG MODE ==="
mkdir -p /app/live/cam1
rm -f /app/live/cam*/*.ts /app/live/cam*/*.m3u8

# SADECE 1 KANAL DENEYELIM - EN BASIT
SRC="http://iptv.prosto.tv:7000/ch331/tracks-v1a1/mono.m3u8"
OUT="/app/live/cam1"

echo "Testing $SRC"
ffmpeg -loglevel info -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 10 -i "$SRC" -t 5 -f null - 2>&1 | head -n 50 &
sleep 6

# Asıl yayın - logosuz, filtresiz, en basit
while true; do
  echo "Starting ffmpeg to $OUT"
  ffmpeg -hide_banner -loglevel info \
  -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 10 -i "$SRC" \
  -c:v libx264 -preset veryfast -b:v 1200k -g 48 -vf scale=1280:720 \
  -c:a aac -b:a 96k \
  -f hls -hls_time 4 -hls_list_size 6 -hls_flags delete_segments -hls_segment_filename "$OUT/%03d.ts" "$OUT/playlist.m3u8"
  echo "ffmpeg crashed, restart in 3s"; sleep 3; rm -f $OUT/*.ts $OUT/*.m3u8
done &
sleep 5
ls -lh /app/live/cam1/
cat > /app/live/index.html <<'HTML'
<h1>TEST</h1><video controls autoplay muted src="/cam1/playlist.m3u8"></video>
HTML
nginx -g 'daemon off;'
