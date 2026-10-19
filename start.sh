#!/bin/sh
echo "=== TEST - RENKLI BARLAR ==="
mkdir -p /app/live/cam1
rm -f /app/live/cam*/*.ts /app/live/cam*/*.m3u8

# Test yayını - internet olmadan bile çalışır
ffmpeg -hide_banner -loglevel error -f lavfi -re -i testsrc=size=1280x720:rate=30 \
-f lavfi -re -i sine=frequency=1000 \
-c:v libx264 -preset veryfast -b:v 1000k -g 30 -c:a aac -b:a 96k \
-f hls -hls_time 4 -hls_list_size 6 -hls_flags delete_segments -hls_segment_filename "/app/live/cam1/%03d.ts" "/app/live/cam1/playlist.m3u8" &
sleep 5
echo "<h1>MIRTI TEST OK</h1><a href='/cam1/playlist.m3u8'>playlist</a><br><video controls autoplay muted src='/cam1/playlist.m3u8' width=640></video>" > /app/live/index.html
ls -lh /app/live/cam1/
nginx -g 'daemon off;'
